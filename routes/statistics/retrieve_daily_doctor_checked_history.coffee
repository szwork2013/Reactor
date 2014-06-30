# 医生当日检查情况
#
# ## 医生当日检查情况
#   + **资源地址**
#   + `/statistics/daily_doctor_checked_history/:date?departments={departments}`
#     * `keywords`：检索条件
#   + **例**
#     `/statistics/daily_doctor_checked_history/2013-03-11?departments=200000000000000000000`
#     `返回数据`
#      {
#        checked_count:1,
#        checked_records:[
#          {
#             barcode: '00000004'
#             name: '王六一'
#             sex: 'female'
#             age: '25'
#          }
#        ],
#        male_unchecked_count:30,
#        female_unchecked_count: 20
#      }
# ## 数据服务（应用于医生工作站）
#   + 根据条件查询数据
#   + 查询成功返回数据，失败发送错误信息。

moment = require "moment"
_      = require "underscore"

app.get '/statistics/daily_doctor_checked_history/:date', authorize('doctor', 'admin'), (req, res) ->
  {Record, Product, Department} = req.models
  date = req.params.date
  doctor_service_departments = req.query.departments?.split(',') or []
  commands = []
  commands.push $match:
    '$or':
      [
        'profile.check_date': date
        'appeared': []
       ,
        'appeared': date
      ]
  commands.push $project:
    barcode: 1
    name: '$profile.name'
    sex: '$profile.sex'
    age: '$profile.age'
    doctors: '$departments.checking.finished.user_id'
    departments: '$departments._id'
    'orders._id': 1
  commands.push $group:
    _id: '1'
    records:
      $push:
        barcode: '$barcode'
        name: '$name'
        sex: '$sex'
        age: '$age'
        doctors: '$doctors'
        departments: '$departments'
        order_ids: '$orders._id'
  Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    # 预约日期下的所有档案信息
    records = results[0]?.records or []
    # console.log records
    # 档案中所有使用了的订单编号
    order_ids  = _.uniq(_.flatten(_.pluck records, 'order_ids'))
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
      # 变形订单数据：键为订单编号，值为项目编号数组的订单项目数组
      order_items = order_items.reduce (memo, order) ->
        memo[order.order_id] = order.items
        memo
      , {}
      commands = []
      commands.push '$project':
        '_id': '$_id'
        'items': '$items._id'
      Department.aggregate commands, (error, results) ->
        return res.send 500, error.stack if error
        # console.log results
        # 变形科室数据： 键为项目编号、值为科室编号
        department_items = results.reduce (memo, result) ->
          if result?.items and result?.items?.length
            for item in result.items
              memo[item] = String(result._id)
          memo
        , {}
        for record in records
          # 如果当前用户编号在档案的所有检查医生编号中，
          # 则该医生已检查此档案
          if req.user?._id in record.doctors?.map((_id) -> _id?.toString())
            record.checked = on
          else
            ischecked = _.intersection(record.departments?.map((id) -> id?.toString()), doctor_service_departments).length
            item_ids  = _.flatten(record.order_ids?.map((order) -> order_items[order]))
            department_ids = _.uniq(item_ids?.map (item) -> department_items[item])
            # 如果档案未检查，且医生负责的科室编号在档案需检查的科室编号中，
            # 则该医生未检查此档案
            if not ischecked and doctor_service_departments.filter((id) -> id in department_ids).length
              record.checked = off
          delete record.doctors
          delete record.order_ids
        checked_records = records.filter((r) -> r.checked is on)
        checked_count   = checked_records.length
        male_unchecked_count = records.filter((r) -> r.checked is off and r.sex is 'male').length
        female_unchecked_count = records.filter((r) -> r.checked is off and r.sex is 'female').length
        res.send
          checked_count: checked_count
          checked_records: checked_records
          male_unchecked_count: male_unchecked_count
          female_unchecked_count: female_unchecked_count
