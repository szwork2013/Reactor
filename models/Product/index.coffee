mongoose   = require 'mongoose'
_          = require "underscore"
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId
redis    = require "node-redis"
redis_client = redis.createClient()
redis_client.subscribe "touch_combos"
pinyin     = require '../../utils/pinyin.coffee'

# TODO: 我们暂不讨论发卡相关的规则。
card_schema =
  number: String
  used: Boolean

card_schema = new Schema(card_schema, {id: false})

card_print_schema =
  _id: ObjectId
  name: String
  cards: [card_schema]

card_print_schema = new Schema(card_print_schema, {id: false})

configuration_schema =
  # TODO: That's by default.
  # 产品编号
  _id: ObjectId
  # 产品名称
  name: String
  # 产品拼音
  name_pinyin: [String]
  # 检查意义
  mean: String
  # 客人主述症状
  results:[String]
  # 性别
  sex: {type: String, enum: ['男', '女']}
  # 年龄下限
  age_lt: Number
  # 年龄上限
  age_ut: Number
  # 团体套餐价格
  discount_price: {type: Number, default: 0}
  # 备注
  note: String
  # 价格
  price: {type: Number, default: 0}
  # 是否常用标识
  popular: {type: Boolean}
  # 团体结算价格
  group_price: Number
  combos: [ObjectId]
  # 项目集合[项目编号]
  items: [ObjectId]
  # 套餐卡集合
  card_prints: [card_print_schema]

configuration_schema = new Schema(configuration_schema, {id: false})

configuration_schema.path('name').set (v) ->
  @name_pinyin = pinyin v
  v

configuration_schema.pre 'save', on, (next, done) ->
  next()
  # 散客价格为空或者低于团体价格，设置散客价格等于团体价格
  if not @price or @price < @discount_price
    @price = @discount_price
  done()

configuration_schema.pre 'save', on, (next, done) ->
  next()
  # TODO: 基础数据可能也有问题。省略这一步可以么?
  # ???如果基础数据都通过下面步骤的话，就会均变成空数组
  return done() if @isNew and @items.length # 基础数据直接跳过
  return done() if @ownerDocument().category is 'combo'
  commands = []
  commands.push
    '$match':
      'configurations._id':
        '$in': @combos
  commands.push
    '$unwind': '$configurations'
  commands.push
    '$match':
      'configurations._id':
        '$in': @combos
  commands.push
    '$project':
      'item': '$configurations.items'
      '_id': 0
  commands.push
    '$unwind': '$item'
  @ownerDocument().model('Product').aggregate commands, (error, results) =>
    return done error if error
    items = results?.map (result) -> result.item
    # TODO: 建议令科室信息实时同步。
    commands = []
    commands.push
      '$match':
        'items._id':
          '$in': items
    commands.push
      '$unwind': '$items'
    commands.push
      '$match':
        'items._id':
          '$in': items
    commands.push
      '$project':
        '_id': '$items._id'
        'sex': '$items.sex'
    @ownerDocument().model('Department').aggregate commands, (error, results) =>
      return done error if error
      results = results?.filter (result) =>
        not @sex or not result.sex? or result.sex is @sex
      items = results.map (result) -> result._id
      @items = items
      done()

product_schema =
  # TODO: That's by default.
  # 大套餐编号
  _id: ObjectId
  # 顺序
  order: Number
  # 大套餐名称
  name:  String
  # 检查意义
  mean: String
  # 适合对象
  target: String
  # 类型（套餐package、组合combo）
  category: {type: String, enum: ['package', 'combo']}
  # 小套餐集合
  configurations: [configuration_schema]
  # 批次编号
  batch: { type: ObjectId, ref: 'Batch'}
  __v: Number

product_schema = new Schema(product_schema, {versionKey: 'myVersionKey', id: off})

product_schema.index
  'batch': 1

product_schema.index
  'category': 1
  'order': 1

product_schema.index
  'category': 1
  'batch': 1
  'order': 1

product_schema.statics.of = (batch_id, cb) ->
  @model('Product').findOne()
  .where('batch').equals(batch_id)
  .select('name configurations._id')
  .select('batch')
  .select('configurations.sex configurations.name')
  .select('configurations.age_lt configurations.age_ut')
  .exec cb

# TODO: 套餐卡暂时不讨论。
# 查询单张套餐卡的价格
product_schema.statics.retrieveCardPrice = (card_number, cb) ->
  commands = []
  commands.push
    $match:
      'configurations.card_prints.cards.number': card_number
  commands.push
    $unwind: '$configurations'
  commands.push
    $unwind: '$configurations.card_prints'
  commands.push
    $unwind: '$configurations.card_prints.cards'
  commands.push
    $match:
      'configurations.card_prints.cards.number': card_number
  commands.push
    '$project':
      'price': '$configurations.price'
      'used':  '$configurations.card_prints.cards.used'
  @aggregate commands, (error, cards) ->
    return cb error if error
    cb null, cards[0]

# TODO: 暂缓套餐卡讨论。
# 查询多张套餐卡的对应价格
product_schema.statics.findPricesByPackageCards = (card_numbers, cb) ->
  return cb null, {} unless card_numbers.length
  commands = []
  commands.push
    $match:
      'configurations.card_prints.cards.number':
        '$in': card_numbers
      'configurations.card_prints.cards.used': off
  commands.push
    $unwind: '$configurations'
  commands.push
    $unwind: '$configurations.card_prints'
  commands.push
    $unwind: '$configurations.card_prints.cards'
  commands.push
    $match:
      'configurations.card_prints.cards.number':
        '$in': card_numbers
      'configurations.card_prints.cards.used': off
  commands.push
    '$project': 
      '_id': '$configurations.card_prints.cards.number'
      'price': '$configurations.price'

  @aggregate commands, (error, cards) ->
    return cb error if error
    cards_price = cards.reduce (memo,item) ->
      memo[item._id] = item.price
      memo
    , {}
    cb null, cards_price

# TODO: 这次先不管套餐卡的。
# 更新套餐卡的使用状态
product_schema.statics.invalid_package_cards = (card_numbers, cb) ->
  return cb() unless card_numbers.length
  @find({'configurations.card_prints.cards.number': {'$in': card_numbers}})
  .select('configurations')
  .exec (error, products) ->
    return cb error if error
    count = products.length
    products.forEach (product) ->
      for c in product.configurations
        for card_print in c.card_prints
          for card in card_print.cards
            if card.number in card_numbers
              card.used = on
      product.save (error, pro) ->
        return cb error if error
        do cb unless --count

# TODO: 再次讨论。有点迷茫。可以加一点设计原因的注释嘛?
# TODO: 我觉得有必要再次讨论。企业版项目是针对产品的，乙肝企业版，丙肝是个人版，这个时候处理方式不同。如果决定对我们的领域暂时仅有乙肝是需要特殊处理的，就改名；如果决定支持企业版的概念，就把企业版按照产品处理。企业版产品个人不知道，其他产品个人可以之情。
# 获取免疫企业版组合编号和组合下的项目编号
product_schema.statics.enterprise_ids = (cb) ->
  @findOne({name: '免疫检验'})
  .select('configurations')
  .exec (error, product) ->
    return cb error if error
    enterprise_combo = []
    enterprise_item = []
    unenterprise_items = []
    for c in product.configurations
      if c.name.match /企业/
        enterprise_combo.push String(c._id)
        for id in c.items
          enterprise_item.push String(id)
      else if c.name.match /乙肝/
        for id in c.items
          unenterprise_items.push String(id)
    cb null, {enterprise_combo: enterprise_combo, enterprise_item: enterprise_item, unenterprise_items: unenterprise_items}

# TODO: 和科室的缓存建议相同，就是不要暴露太多外界不使用的东西。
product_schema.statics.cache = (cb) ->
  redis_client.on "message", (channel, message) =>
    @set_hasnt_item_combos_cache(@) if channel is 'touch_combos'
  @set_hasnt_item_combos_cache(@, cb)

product_schema.statics.set_hasnt_item_combos_cache = (model, cb) ->
  model.find()
  .select('name configurations._id configurations.name')
  .select('configurations.note configurations.items')
  .where('category').equals('combo')
  .sort('order')
  .exec (error, combos) =>
    return cb error if error
    hasnt_item_combos = {}
    configurations_index = {}
    combo_note = {}
    for combo in combos
      # TODO: configuration
      for configuration, index in combo.configurations
        combo_note[configuration._id] = configuration.note if configuration.note
        configurations_index[configuration._id] = index
        if not configuration.items.length
          hasnt_item_combos[configuration._id] = configuration.name
    model.hasnt_item_combos = hasnt_item_combos
    model.combos = combos
    model.combo_note = combo_note
    radiology_combo = _.find combos, (c) -> c.name.match(/放射/)
    radiology_combo_items = {}
    for config in radiology_combo?.configurations
      radiology_combo_items[config._id] = name: config.name, items: config.items
    model.radiology_combo_items = radiology_combo_items
    model.configurations_index  = configurations_index
    cb?()

# 返回所有订单编号对应的组合名称
product_schema.statics.get_combos_by_orderids = (orderids, cb) ->
  orderids = _.uniq(orderids.map (id) -> id.toString())
  small_combos = {}
  for combo in @combos
    for configuration in combo.configurations
      small_combos[configuration._id] = configuration.name
  @find({'configurations._id': {'$in': orderids}})
  .exec (error, products) ->
    return cb error if error
    combos = {}
    for product in products
      for configuration in product.configurations
        if configuration._id.toString() in orderids
          combos[configuration._id] or = []
          combos[configuration._id].push small_combos[configuration._id] if small_combos[configuration._id]
          for id in configuration.combos
            combos[configuration._id].push small_combos[id]
    cb null, combos

# 返回所有订单编号对应的没有项目集合的组合名称
# TODO: 在`get_record_by_barcode`这个流程中组装好档案必须信息吧。这个信息可以持久化。
# TODO: router中除去渲染逻辑，档案中信息最好都齐全。
product_schema.statics.get_hasnt_item_and_radiology_item_combos_by_orderids = (orderids, cb) ->
  orderids = _.uniq(orderids.map (id) -> id.toString())
  @find({'configurations._id': {'$in': orderids}})
  .exec (error, products) =>
    return cb error if error
    hasnt_item_combos = []
    radiology_combos = []

    for product in products
      for config in product.configurations
        if config._id.toString() in orderids
          radiology_combos.push @radiology_combo_items[config._id] if @radiology_combo_items[config._id]
          hasnt_item_combos.push  @hasnt_item_combos[config._id] if @hasnt_item_combos[config._id]
          for id in config.combos
            radiology_combos.push @radiology_combo_items[id] if @radiology_combo_items[id]
            hasnt_item_combos.push  @hasnt_item_combos[id] if @hasnt_item_combos[id]

    radiology_item_combos = {}
    for combo in radiology_combos
      for item in combo.items
        radiology_item_combos[item] or = []
        radiology_item_combos[item].push combo.name

    cb null, hasnt_item_combos, radiology_item_combos

product_schema.pre 'save', (callback) ->
  @increment()
  callback()

module.exports = product_schema
