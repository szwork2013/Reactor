mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
_        = require 'underscore'
redis    = require "node-redis"
redis_client = redis.createClient()
redis_client.subscribe "touch_departments"
{detail_to_expstr, conditions_to_string, string_to_conditions, calibrate_precision, variant_detail_to_conditions} = require "../../utils/util.coffee"

# TODO: 这种几百行的程序，如果不能分开，就利用
# Markdown的标题级别将起各部分划分开。

# TODO: 下划线小写。
conditionSchema =

  #   0.   **分组**
  #   1. ! **症状名称**，经调整后详细名称；
  #   # TODO: 建议分级，症状不再分级。
  #   2.   **症状分级**，`A`（级）最为严重，允许格式`A`、`B`、`C`；
  #   # TODO: 症状不再直接伴有建议。
  #   3.   **建议**，允许无建议；
  #   4.   **详细描述**，支持选择语法（左、右、双）与数字占位符，如无详细描述，则无该键；
  #   # TODO: 科室项目中症状无需汇总名称，汇总建议中有；
  #   # TODO: 对偏高、偏低的症状反应堆自动生成症状名称：血常规白细胞偏高。
  #   5.   **汇总名称**，影响个检报告的建议汇总，亦影响团检报告；
  #   6.   **表达式**，根据项目`value`自动匹配症状。
  group      : String
  name       : String
  level      : {type: String, enum: ['A', 'B', 'C']}
  description: String
  detail     : String
  # TODO: 计算键不持久化。
  detail_expstr: String
  summary    : String
  expression : String

conditionSchema = new Schema conditionSchema, {versionKey: off, id: off, _id: off}

# TODO: 使用虚拟键，不持久化。
# TODO: 在不恐惧Mongoose的测试之后，这个算法仅仅在此使用吗？如是，不要写道其他地方去。
# TODO: 在可测试行上是相同的，但是在代码扇出系数上是不同的：P
conditionSchema.path('detail').set (v) ->
  @detail_expstr = detail_to_expstr v
  v

itemSchema =
  # TODO: Mongoose assigns each of your schemas an _id field by default.
  _id: ObjectId
  # 项目名称
  name : String
  # 项目简称
  abbr: String
  # 简写
  byname: [String]
  # 项目类型type ：
  #   + `number`：数值类型
  #   + `text`  ：文本类型
  # TODO: 不再关心数值还是文本了。即使标记了数值或文本，在应用中，临床检查中数值项目全部都需要特殊处理；
  # TODO: 实验室应用全部按照数值进行处理即满足需求。
  category: {type: String, enum: ['number', 'text']}
  # 上限(仅限number类型)
  ut: String
  # 下限(仅限number类型)
  lt: String
  # 单位(仅限number类型)
  unit: String
  # 性别
  sex: String
  # TODO: 下面两个能想办法并键么?
  # 项目默认情况
  default : String
  value_default: String
  description: String
  # 项目表达式
  expression : String
  # 项目小结
  conditions : [conditionSchema]
  # 项目小结建议字符串
  conditions_string : String

itemSchema = new Schema itemSchema, {versionKey: off, id: off}

# TODO: 同样将逻辑直接叙述在此处。测试起来也蛮直接的。
itemSchema.path('conditions_string').set (v) ->
  @conditions = string_to_conditions v
  v

# ## ItemSchema 部分
# 确保上下限有效数字统一
# TODO: 这样写法在档案的科室项目中出现了栈溢出。为什么会出现？
# TODO: 如果有调整必要，参考一下科室项目上下限的处理方法。
# TODO: 科室上下限有一些是表达式的，不需要调整有效数字。在档案中再调整。
# TODO: 目前，调整性别后，仅能够删除性别不符合的项目，但是尚未调整项目上下限。
itemSchema.path('ut').set (ut) ->
  [lt, ut] = calibrate_precision @lt, ut
  @lt = lt if lt
  ut

itemSchema.path('lt').set (lt) ->
  [lt, ut] = calibrate_precision lt, @ut
  @ut = ut if ut
  lt

# TODO: 需要虚拟键和Getter么?
itemSchema.set 'toJSON', {getters: on, virtuals: on}

# TODO: 能不能给项目的值一个setter，让项目模型自己管理如何匹配症状的事情?
# TODO: 在导入项目的时候，只需要赋值就好了。

# 对临床科室项目维护应用中以下项目进行修正
#
# 1. 身高
# 2. 体重
# 3. 体重指数
# 6. 血压
# 7. 心率
# 8. 视力
# 9. 非接触眼压
# 10.骨密度
# 11.宫颈超薄细胞学检查
# 12.胸部正位片
# 13.神经系统
# 14.附件
# 15.其他
# TODO: 是不是一个post init的中间件更好一点? 我想错了，post init中间件仅仅在从mongodb中取数据才会起作用。
itemSchema.pre 'save', (next) ->
  # TODO: else @default = '未见明显异常' unless @default
  @default = '未见明显异常' unless @default
  switch @name
    when '身高'
      @category = 'number'
      @unit = 'cm'
    when '体重'
      @category = 'number'
      @unit = 'kg'
    when '体重指数'
      @category = 'number'
      #@unit = 'kg/m<sup>2</sup>'
    when '血压'
      @category = 'number'
      @unit = 'mmHg'
    when '心率'
      @category = 'number'
      @unit = '次/分'
      @lt = '60'
      @ut = '100'
    when '视力'
      @category = 'number'
    # when '非接触眼压'
    # @category = 'number'
    # @unit = 'mmHg'
    # @lt = '10'
    # @ut = '21'
    when '超声骨密度'
      @default = '正常骨密度'
    when '宫颈超薄细胞学检查'
      @default = '未见上皮内病变和癌细胞'
    when '神经系统'
      @default = '膝反射未见异常'
    when '附件'
      @default = '双附件未见明显异常'
    when '心电图'
      @default = '窦性心律，正常心电图'
    when '病史'
      @default = '无'
    when '手术史'
      @default = '无'
    when '其他'
      @default = '无'
  next()

departmentSchema =
  # 科室编号
  _id : ObjectId
  # 科室显示顺序
  order: Number
  # 科室名称
  name : String
  # 检查应用突出提示的相关科室的名称。
  references: [String]
  # 图片位置
  image_path: String
  # 科室类型（临床类型或者实验室类型、放射检查）[clinic|laboratory|radiology]
  # 采样工作站需要将类型为blood_test的科室里面的项目查询出来，便给科室添加采样信息。
  # 技师工作站将类型为radiology的科室里所有的项目查询出来，给项目添加采样信息
  # TODO: [物理检查|实验室检查]
  category: {type: String, enum: ['clinic', 'laboratory', 'radiology']}
  # TODO: 科室不再需要默认综述了。
  # 默认综述
  default: String
  # 门牌号
  door_number: [String]
  # 房间名称
  # TODO: 在逻辑上设计成为可选键，如无该键，取科室名称。
  door_name: String
  # 项目
  items: [itemSchema]

module.exports = departmentSchema = new Schema departmentSchema, {versionKey: off, id: off}

# TODO: 科室模型是否不再需要状态?
departmentSchema.virtual('status').get () ->
  @_status

departmentSchema.virtual('status').set (v) ->
  @_status = v

# TODO: 其实也没有getter和virtual。
departmentSchema.set 'toJSON', {getters: on, virtuals: on}

# 对特殊科室项目默认值进行设置。
departmentSchema.pre 'save', (next) ->
  item = _.find @items, (item) -> item.name in ['肾', '肾脏']
  # TODO: 这个也统一放在上面的pre save中，可以通过@parent()获得项目对象。按照目前的科室与项目进行常量比较，无需适应名称微调了。
  if item and @name?.match /内科/
    item.default = '双肾区无扣痛'
  else if item and @name?.match /.*(彩超|超声)/
    item.default = '双肾未见明显异常'

  # TODO: 科室不需要默认情况。
  @default = '未见明显异常'
  # TODO: 科室不需要默认情况，项目上已有正常骨密度的默认字样了。
  if @name is '超声骨密度'
    @default = '正常骨密度'
  # TODO: 科室类别在coffee中叙述。
  else if @name is '心电图'
    @default = undefined
  next()

# TODO: do cache = ->
# redis_client.on "message", (channel, message) ->
#   cache() if ...
# TODO: 意思就是那个preemptive_cache不要暴露出来。
departmentSchema.statics.cache = (cb) ->
  redis_client.on "message", (channel, message) =>
    @set_preemptive_cache(@) if channel is 'touch_departments'
  @set_preemptive_cache(@, cb)

departmentSchema.statics.set_preemptive_cache = (model, callback) ->
  # TODO: 这个model是不是@?
  model.find()
  # TODO: 能让mongodb给排好顺序嘛？ 
  .exec (error, departments) =>
    return callback?(error) if error
    # TODO: 首先，这段东西，斧凿的痕迹挺明显的，你看：
    # TODO: 我们能不能不对科室文档做进一步变换，仅仅存于@departments  = departments
    # TODO: 而在后续使用时注意使用模式，和toObject()等方式避免碰到原始科室的数据? 考虑一下?
    # 求得科室顺序。
    departments = departments.sort (a, b) ->
      # TODO: 这个行连接没必要的。
      if a.category > b.category then 1 \
      else if a.category < b.category then -1 \
      else if a.order > b.order then 1 \
      else -1
    model.cached_departments = departments
    departments_orders = {}
    departments_orders[d._id] = i for d, i in departments
    departments = departments.map (d) -> d.toObject()
    items_orders = {}
    variant_departments = {}
    detail_expstr_hash = {}
    cached_items = {}
    for department in departments
      expression_items = department.items.filter (i) -> i.expression
      items_hash = {}
      for item, index in department.items
        item.normal = item.default
        items_orders[item._id] = index
        items_hash[item.name.toUpperCase()] = item
        items_hash[item.abbr.toUpperCase()] = item if item.abbr
        if item.byname.length
          items_hash[name] = item for name in item.byname
        cached_items[item._id] = item.name
        for condition in item.conditions
          # TODO: 这个症状名称恐不唯一，可能需要科室名称作为前缀，或者科室|项目|症状的格式。
          detail_expstr_hash[condition.name] = condition.detail_expstr if condition.detail?
      # TODO: 这两个对象常量写一次就可以了。
      variant_departments[department.name] =
        _id: department._id
        name: department.name
        category: department.category
        items_hash: items_hash
        expression_items: expression_items
      variant_departments[department._id] =
        _id: department._id
        name: department.name
        category: department.category
        items_hash: items_hash
        expression_items: expression_items
    # TODO: 有了pub/sub之后，使用者已经不会感觉到这是一个陈旧内容了，命名上可以调整一下了。
    model.cached_departments_orders = departments_orders
    model.cached_items_orders = items_orders
    # TODO: Department.departments, 其中有`order`键。
    model.cached_departments_hash = variant_departments
    # TODO: Department.detail_regexps
    model.cached_detail_expstr_hash = detail_expstr_hash
    model.cached_items = cached_items
    callback?()

# 无需击`mongodb`，由`node.js`进程缓存中，根据`id`取得某科室。
departmentSchema.statics.id = (id) -> @cached_departments_hash[id]

# 无需击`mongodb`，由`node.js`进程缓存中，根据`id`克隆某科室。
departmentSchema.statics.clone = (id) -> JSON.parse JSON.stringify @id(id)

# TODO: 这个是否可以永别了?
departmentSchema.statics.get_departments_conditions = (cb) ->
  @find()
  .select('name items.name items.conditions')
  .exec (error, departments) ->
    return cb error if error
    conditions = []
    for department in departments
      conditions.push department.name
      for item in department.items
        conditions.push item.name
        conditions.push department.name + item.name
        for condition in item.conditions
          conditions.push (if condition.name in ['偏低', '偏高', '阳性', '阴性', '弱阳性'] then item.name + condition.name else condition.name)
          conditions.push condition.summary if condition.summary?
    cb null, conditions
