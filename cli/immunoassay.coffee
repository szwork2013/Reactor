# 当天免疫需检查项目
#
# ## 免疫需检查项目
#   + **资源地址**
#   + `/statistics/immunoassay/:date`
#     * `keywords`：检索条件
#   + **例**
#     `/statistics/immunoassay/2013-02-20`
#     `返回数据`
#     [{
#       name: '免疫',
#       cells: [
#         ['编号', '项目1', '项目2', '项目3', '项目4'],
#         ['00000001', '', '','', '无'],
#         ......
#       ]
#     }]
# ## 数据服务（应用于下载免疫需检查项目Excel）
#   + 根据条件查询数据
#   + 查询成功返回数据，失败发送错误信息。
_       = require "underscore"
request = require "superagent"

# app.get '/statistics/immunoassay/:date', authorize('doctor', 'admin'), (req, res) ->
require('../models') 'hswk.healskare.com', (error, models) ->
  mongoose = require 'mongoose'
  mongoose.set 'debug', off
  {Record, Product, Department} = models
  # {date} = req.params
  date = process.argv[2]
  Department.findOne({name: '免疫检验'})
  .select('name category items._id items.abbr items.name')
  .exec (error, department) ->
    return res.send error.stack if error
    sampling_name = department.required_samplings[0]
    # 免疫科室所有项目数组
    item_ids = department.items.reduce (memo, item) ->
      memo.push item._id.toString()
      memo
    , []
    # 变形免疫科室项目，键为项目编号，值为项目简写，如果没有简写则为名称
    items = department.items.reduce (memo, item) ->
      memo[item._id] = item.abbr or item.name
      memo
    , {}
    commands = []
    commands.push $match:
      'samplings.sample.date_string': date
      'samplings.name': sampling_name
    commands.push $project:
      barcode: 1
      samplings: '$samplings'
      name: '$profile.name'
      sex: '$profile.sex'
      source: '$profile.source'
      age: '$profile.age'
      'sign_agreement': 1
      'orders._id': 1
      'orders.paid': 1
    commands.push $unwind: '$orders'
    commands.push $match: 
      'orders.paid':
        '$ne':0
    commands.push '$unwind': '$samplings'
    commands.push '$match':
      'samplings.sample.date_string': date
      'samplings.name': sampling_name
    commands.push '$group':
      _id:'$barcode'
      sign_agreement:
        '$last': '$sign_agreement'
      source:
        '$last': '$source'
      name:
        '$last': '$name'
      sex:
        '$last': '$sex'
      age:
        '$last': '$age'
      order_ids:
        '$push': '$orders._id'
    commands.push '$sort':
      '_id': 1
    Record.aggregate commands, (error, records) ->
      return res.send 500, error.stack if error
      # 免疫科室已抽血的订单编号集合
      order_ids  = _.uniq(_.flatten(_.pluck records, 'order_ids'))
      Product.get_combos_by_orderids order_ids, (error, order_combos) ->
        res.send 500, error.stack if error
        # 档案编号对应的所有组合名称
        barcode_combos = records.reduce (memo, record) ->
          combos = []
          for order in record.order_ids
            combos = combos.concat order_combos[order]
          memo[record._id] = combos
          memo
        , {}
        commands = []
        commands.push $match:
          'configurations._id':
            '$in': order_ids
        commands.push $unwind: '$configurations'
        commands.push $match:
          'configurations._id':
            '$in': order_ids
        commands.push $project:
          _id: 0
          order_id: '$configurations._id'
          items: '$configurations.items'
        Product.aggregate commands, (error, order_items) ->
          return res.send 500, error.stack if error
          # 变形订单数据：键为订单编号，值为项目编号数组
          order_items = order_items?.reduce (memo, order) ->
            memo[order.order_id] = order.items
            memo
          , {}
          Product.enterprise_ids (error, ids) ->
            return res.send 500, error.stack if error
            # 给每个档案添加项目数组，来自订单下的且是免疫科室中的项目编号
            for record in records
              record.items = []
              for order_id in record.order_ids
                for id in order_items[order_id]
                  console.log order_id, id
                  record.items.push id.toString() if id.toString() in item_ids
              console.log record._id, record.items # if record.barcode is '10000799'
              #if not barcode_combos[record._id]?.some((combo) -> combo.match /企业/ )
                #record.items = record.items.filter((id) -> id not in ids.unenterprise_items) unless record.sign_agreement
            
            # 订单免疫科室项目编号全集
            all_item_ids  = _.uniq(_.flatten(_.pluck records, 'items'))
            {cached_departments_hash} = Department
            orders = {}
            mianyi_departments_hash = cached_departments_hash['免疫检验']
            orders[mianyi_departments_hash.items_hash['HBSAG']?._id] = 1
            orders[mianyi_departments_hash.items_hash['HBSAB']?._id] = 2
            orders[mianyi_departments_hash.items_hash['HBEAG']?._id] = 3
            orders[mianyi_departments_hash.items_hash['HBEAB']?._id] = 4
            orders[mianyi_departments_hash.items_hash['HBCAB']?._id] = 5
            orders[mianyi_departments_hash.items_hash['AFP']?._id] = 6
            orders[mianyi_departments_hash.items_hash['CEA']?._id] = 7
            orders[mianyi_departments_hash.items_hash['T-PSA']?._id] = 8
            orders[mianyi_departments_hash.items_hash['T']?._id] = 21
            orders[mianyi_departments_hash.items_hash['T3']?._id] = 22
            orders[mianyi_departments_hash.items_hash['FT3']?._id] = 23
            orders[mianyi_departments_hash.items_hash['T4']?._id] = 24
            orders[mianyi_departments_hash.items_hash['FT4']?._id] = 25
            orders[mianyi_departments_hash.items_hash['TSH']?._id] = 26
            orders[mianyi_departments_hash.items_hash['HP']?._id] = 27
            all_items = all_item_ids.reduce (memo, id) ->
              memo.push {_id: id, order: orders[id] or 20}
              memo
            , []
            all_items = all_items.sort (a, b) -> if a.order > b.order then 1 else -1
            all_item_ids = _.pluck all_items, '_id'
            # 变形订单免疫项目名称全集
            titles = all_item_ids?.reduce (memo, id) ->
              memo.push items[id]
              memo
            , []
            titles.unshift('年龄')
            titles.unshift('性别')
            titles.unshift('姓名')
            titles.unshift('采血管号')
            titles.unshift('来源')
            titles.unshift('编号')
            data = []
            data.push titles
            # 如果档案的免疫项目中无全集的某项目则为'无'
            for record in records
              check_data = [record._id, record.source, record._id + '02', record.name, record.sex, record.age]
              for id in all_item_ids
                check_data.push (if id.toString() in record.items then '√' else '无')
              data.push check_data
              # console.log data
            # process.exit()
            request.post("http://kells.cloudapp.net/convert/JsonToExcel")
            .send(JSON.stringify([{name: date + '免疫', cells: data}]))
            .set('Content-Type', 'text/plain')
            .end (res2) =>
              console.log res2.text
              process.exit()
              # res.redirect res2.text
