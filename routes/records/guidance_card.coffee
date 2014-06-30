# 打印导检卡
#
# ## 个人打印和团体打印
#   + **资源地址**
#   + `/records/:barcode/guidance_card?guidance_card_printed=true`
#     * `id`：编号或者barcode
#   + **例**
#      `/records/00000004/guidance_card`
# ## 数据服务（应用于个人或团体导检卡打印）
#   + 根据条件查询数据
#   + 查询成功返回数据，失败发送错误信息。

moment  = require 'moment'
moment.lang('zh-cn')
_       = require 'underscore'
barcode = require '../../utils/barcode.coffee'

app.get '/records/:barcode/guidance_card', authorize('cashier', 'admin'), (req, res) ->
  {Department, Record, Product, Route, Configuration} = req.models
  Record.barcode req.params.barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    record = record.toJSON()
    orderids = _.pluck record.orders, '_id'
    Product.get_hasnt_item_and_radiology_item_combos_by_orderids orderids
    , (error, hasnt_item_combos, radiology_item_combos) ->
      return res.send 500, error.stack if error
      # 导检卡信息
      card =
        name: record.profile.name
        sex:  record.profile.sex
        age:  record.profile.age
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
      #samplings = []
      #record.departments.filter((d) -> d.name.match(/尿.*/) or d.name.match(/便.*/))
      #.forEach (d) ->
      # if not record.samplings.some((sampling) -> sampling.status is '已采样' and sampling.name is d.required_samplings?[0])
      #   samplings = samplings.concat d.required_samplings
    
      samplings = record.samplings.filter((s) -> s.name.match(/尿|便|基因|乙肝|HBV/) and s.status in ['未付费', '未采样'])
      samplings = _.pluck samplings, 'name'
      
      # 提示信息
      card.note = if samplings.length then "#{samplings.sort().join '、'}" else ''

      # 排除尿常规和便潜血
      record.departments = record.departments.filter (d) ->  not d.name?.match(/便.*/) and not d.name?.match(/尿.*/)
    
      # 科室集合变形键值对，键为科室编号，值为房间名称和门牌号
      departments = record.route?.departments.reduce (memo, d) ->
        memo[d._id] = door_name: d.door_name, door_number: d.door_number
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
          fuke = _.find record.route.departments, (depart) -> depart.door_name is '妇科'
          d.room_id = fuke?._id or ''
          d.door_name = fuke?.door_name or ''
          d.door_number = fuke?.door_number or ''
       #else if d.name.match(/腹部(超声|彩超)/) or d.name.match(/乳腺(超声|彩超)/)
       #   d.room_id = ultrasound_room['id']
       #  d.door_name = ultrasound_room['name']
       #  d.door_number = if card.sex is '男' then ultrasound_room['door_number'][0]
       #  else ultrasound_room['door_number'][1]
        else
          d.room_id     = d._id
          d.door_name   = departments[d._id]?.door_name or ''
          d.door_number = departments[d._id]?.door_number or ''

      special_combos = [
        '中医问诊'
        '冲击波体验'
        '检后咨询'
        '步态监测'
        '早餐'
      ]
      # 如果套餐中显示早餐则给档案科室添加早餐
      for name in special_combos
        if hasnt_item_combos.some((combo) -> combo.match name)
          room = Configuration[name]
          record.departments.push {room_id: room?['id'], door_name: name}
      
      # 根据路线编号给档案科室进行分组
      rooms = _.groupBy record.departments, (d) -> d.room_id
      
      # 路线中各科室的顺序
      room_orders = {}
      if record.route
        room_orders[d._id] = i for d, i in record.route?.departments

      # 腹部超声在导检卡上需要出产品
      fubuchaosheng = [
        name: '腹部超声'
        items: [
          '700000000000000000000001'
          '700000000000000000000002'
          '700000000000000000000003'
          '700000000000000000000004'
          '700000000000000000000005'
          '700000000000000000000008'
        ]
       ,
        name: '前列腺超声'
        items: [
          '700000000000000000000006'
        ]
       ,
        name: '子宫附件超声'
        items: [
          '700000000000000000000007'
        ]
       ,
        name: '心脏超声'
        items: [
          '7000000000000000000000a9'
        ]
      ]
      item_name = fubuchaosheng.reduce (memo, item) ->
        for item_ in item.items
          memo[item_] = item.name
        memo
      , {}
      # 遍历分组后的档案科室键值对，对各科室的房间名称、门牌号、顺序、状态
      card.rooms = for room_id, departments of rooms
        card_department =
          door_name  : departments[0].door_name
          door_number: departments[0].door_number or ''
          order      : room_orders[room_id] ? Infinity
          items: []
        if departments[0].name is '放射科'
          for item in departments[0].items
            if radiology_item_combos[item._id]
              for combo_name in radiology_item_combos[item._id]
                card_department.items.push combo_name
        if departments[0].name is '腹部彩超'
          card_department.door_name = ''
          names = for item in departments[0].items
            item_name[item._id.toString()]
          card_department.items =  _.uniq names
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
      res.render 'guidance_card', card
      if req.query.guidance_card_printed
        Record.update { barcode: record.barcode}, { '$set': { 'guidance_card_printed': on } }, { safe: true }
        , (error, numberAffected) ->
          console.log error.stack if error
