#批量打印导检卡
#
# ## 团体打印
#   + **资源地址**
#   + `/batches/:batch_id/guidance_cards`
#     * `id`：编号或者barcode
#   + **例**
#      `/batches/00000004/guidance_cards`
# ## 数据服务（应用于个人或团体导检卡打印）
#   + 根据条件查询数据
#   + 查询成功返回数据，失败发送错误信息。

moment = require 'moment'
async  = require 'async'
moment.lang('zh-cn')
_       = require 'underscore'
barcode = require '../../utils/barcode.coffee'

app.get '/batches/:batch_id/guidance_cards', authorize('cashier', 'admin'), (req, res) ->
  {Department, Record, Product, Route, Configuration} = req.models
  #{} = req.params
  Department.find()
  .select('name door_number door_name')
  .exec (error, departments2) ->
    gynecology = _.find departments2, (d) -> d.name is '妇科'
    return res.send 500, error.stack if error
    Record.find({'profile.batch': req.params.batch_id, 'appeared': []})
    .populate('route', 'departments')
    # .sort('profile.division')
    .exec (error, records) ->
      return res.send 500, error.stack if error
      records = records.map (record) -> record.toJSON()
      cards = []
      tasks = records.map (record) -> (callback) ->
        orderids = _.pluck record.orders, '_id'
        Product.get_hasnt_item_combos_by_orderids orderids, (error, hasnt_item_combos) ->
          return res.send 500, error.stack if error
          # 导检卡信息
          card =
            name: record.profile.name
            sex:  record.profile.sex
            age:  record.profile.age
            py: record.profile.name[0] + record.profile.pinyin[0][0]
            barcode: barcode {code: record.barcode, crc: off}, 'int25'
            source: if record.profile.source isnt '个检' then record.profile.source else ''
            division: record.profile.division
            rooms: []

          # 客人基本信息和预约时间
          check_date      = moment(record.profile.check_date)
          card.weekday    = moment(check_date).format('dddd')
          card.check_date = moment(check_date).format 'MM-DD'
          card.check_time = _.find(Configuration.reservation_time_ranges, (r) -> r.value is record.profile.check_time)?.label

          # 是否领取尿便盒
          samplings = []
          record.departments.filter((d) -> d.name.match(/尿.*/) or d.name.match(/便.*/))
          .forEach (d) ->
            if not record.samplings.some((sampling) -> sampling.status is '已采样' and sampling.name is d.required_samplings[0])
              samplings = samplings.concat d.required_samplings
          
          # 提示信息
          card.note = if samplings.length then "#{samplings.sort().join '、'}" else ''

          # 排除尿常规和便潜血
          record.departments = record.departments.filter (d) ->  not d.name?.match(/便.*/) and not d.name?.match(/尿.*/)
        
          # 科室集合变形键值对，键为科室编号，值为房间名称和门牌号
          departments = departments2.reduce (memo, d) ->
            number = if d.door_number?.length is 2 and card.sex is '女' then d.door_number[1]
            else d.door_number[0]
            memo[d._id] = { door_name: d.door_name or '', door_number: number or ''}
            memo
          , {}
          
          blood_sampling_room = Configuration['采血室']
          ultrasound_room     = Configuration['常规超声']

          # 给档案各科室增补路线编号、房间名称、门牌号
          record.departments.forEach (d) ->
            if d.category is 'laboratory' and (d.required_samplings?.some (s) -> s.match /采血/)
              d.room_id = blood_sampling_room['id']
              d.door_name = blood_sampling_room['name']
              d.door_number = blood_sampling_room['door_number'][0]
            else if d.name.match(/宫颈.*细胞学/) or d.name.match(/妇科/) or d.name.match(/宫颈刮片/) or d.name.match(/白带常规/)
              d.room_id = gynecology._id
              d.door_name = gynecology.door_name
              d.door_number = gynecology.door_number[0] or ''
            else if d.name.match(/腹部(超声|彩超)/) or d.name.match(/乳腺(超声|彩超)/)
              d.room_id = ultrasound_room['id']
              d.door_name = ultrasound_room['name']
              d.door_number = if card.sex is '男' then ultrasound_room['door_number'][0]
              else ultrasound_room['door_number'][1]
            else
              d.room_id = d._id
              d.door_name = departments[d._id]?.door_name or ''
              d.door_number = departments[d._id]?.door_number or ''
         
          special_combos = [
            '冲击波体验'
            '中医问诊'
            '检后咨询'
            '基因检测'
            '步态监测'
            '早餐'
          ]
          # 如果套餐中显示早餐则给档案科室添加早餐
          for name in special_combos
            if hasnt_item_combos.some((combo) -> combo.match name)
              room = Configuration[name]
              record.departments.push {room_id: room['id'], door_name: name}

          # 根据路线编号给档案科室进行分组
          rooms = _.groupBy record.departments, (d) -> d.room_id
          
          # 路线中各科室的顺序
          room_orders = {}
          if record.route
            room_orders[d] = i for d, i in record.route?.departments

          # 遍历分组后的档案科室键值对，对各科室的房间名称、门牌号、顺序、状态
          card.rooms = for room_id, departments of rooms
            card_department =
              door_name  : departments[0].door_name
              door_number: departments[0].door_number or ''
              order      : room_orders[room_id] ? Infinity
              items: []
            card_department.items = _.pluck departments[0].items, 'name' if departments[0].name is '放射科'
            if room_id is Configuration['早餐'].id
              card_department.status = 'breakfast'
            else if (departments.some (d) -> d.status in ['未完成', '未采样', '未付费']) or (card_department.door_name in special_combos)
              card_department.status = 'incomplete'
            else if (departments.some (d) -> d.status is '延期')
              card_department.status = 'reschedule'
            else if (departments.every (d) -> d.status is '放弃')
              card_department.status = 'giveup'
            else
              card_department.status = 'complete'
            card_department
        
          # 排序
          card.rooms = card.rooms.sort (a, b) -> if a.order - b.order > 0 then 1 else -1
          cards.push card
          callback()

      async.parallel tasks, () ->
        cards = cards.sort (a, b) ->
          if a.division > b.division then -1 \
          else if a.division < b.division then 1 \
          else if a.py > b.py then 1 \
          else -1
        res.render 'guidance_cards', {cards: cards}
        barcodes = _.pluck records, 'barcode'
        Record.update { barcode: {'$in': barcodes}}, { '$set': { 'profile.guidance_card_printed': on } }, { safe: true, multi: true}
        , (error, numberAffected) ->
          console.log error.stack if error

