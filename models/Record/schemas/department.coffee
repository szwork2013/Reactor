mongoose = require 'mongoose'
_        = require 'underscore'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
event    = require "../../Shared/event.coffee"
{calc_threshold, calc_value, calc_conditions, calibrate_precision} = require "../../../utils/util.coffee"

# TODO: 不需要summary了。
condition_schema =
  name       : String
  detail     : String
  summary    : String

condition_schema = new Schema condition_schema

# **说明**：
#
#   1. @ 表示由服务器强制管理；
#   2. ! 表示必选键；
#   3. 全部键如存在时必须满足有效格式。

# ## 项目建模
item_schema =

  # ### 项目基本信息
  #
  # 检查项目数组中每一对象包括：
  # 
  #   1. ! **项目编号**
  #   2. ! **项目名称**
  #   3.   **项目简称**
  #   4. 放射科胸部正位片症状详细描述
  #   5. ! **项目类型** [text|number]
  #   6.   **适用性别** [male|female]
  #   7.   **值**       (仅限number类型,为了保证有效数字的精度，值与上下限采用字符串类型)
  #   8.   **单位**     (仅限number类型)
  #   9.   **参考下限** (仅限number类型)
  #   10.  **参考上限** (仅限number类型)
  #   11.  **备注**     [延期|放弃]（暂存中文）
  _id      : ObjectId
  name     : String
  abbr     : String
  byname   : [String]
  # 在生成pdf时需要此键
  category : {type: String, enum: ['text', 'number']}
  sex      : {type: String, enum: ['男', '女']}
  value    : String
  normal   : String
  unit     : String
  lt       : String
  ut       : String
  #note     : {type: String, enum: ['延期', '放弃']}
  # TODO: 枚举类型定义。{type: String, enum: ['未完成', '未付费', '延期', '放弃', '未完成', '已完成']}
  status   : {type: String, enum: ['未到场', '未付费', '延期', '放弃', '未完成', '待检验', '已完成']}
  description: String
  # ### 检查信息
  # 纪录放射科检查时间
  checking :
    start    : event
    finished : event
  # ### 项目检出症状
  conditions: [condition_schema]

item_schema = new Schema(item_schema, {versionKey: off, id: off})

# ## ItemSchema 部分
# 确保上下限有效数字统一
# TODO: SPEC ME!!!
item_schema.path('ut').set (ut) ->
  # console.log 'ut'
  @_ut = ut
  [lt, ut] = calibrate_precision @lt?.toString(), ut?.toString()
  @lt = lt if lt isnt @_lt
  ut

item_schema.path('lt').set (lt) ->
  @_lt = lt
  [lt, ut] = calibrate_precision lt?.toString(), @ut?.toString()
  # console.log ut, @_ut
  @ut = ut if ut isnt @_ut
  lt

item_schema.path('value').set (value) ->
  return value if not @lt? and not @ut?
  precision  = (@lt?.split('.')[1]?.length or @ut?.split('.')[1]?.length) or 0
  if not isNaN(value.trim()*1) then parseFloat(value.trim()).toFixed(precision) else value.trim()

original_department = null

# A:找到参考项目, B:找到档案项目
# 1. 将A的全部键值赋予B
# 2. 根据Profile和A，更新B的ut、lt
# 3. 将item的value和normal赋予B
# 4. 计算B的conditions
item_schema.methods.set_item = (department, item, original_item) ->
  _.extend @, original_item
  profile = @ownerDocument().profile
  calc_threshold @, profile
  @value  = item.value if item.value?
  @value  = calc_value item.expression, department if item.expression?
  @description = item.description if item.description?
  if item.conditions?.length and (not item.value or item.name.match('骨密度'))
    @conditions = item.conditions
  else
    @conditions = calc_conditions @, profile
  @normal = if @conditions.length then undefined else original_item.default
  found_item = _.find original_department.expression_items, (item_) -> item_.expression.match(new RegExp(original_item.name))
  if found_item
    item2 = _.find department.items, (item_) -> item_.name is found_item.name
    item2.set_item department, {name: item2.name, expression: found_item.expression}, found_item

# ## 科室建模
department_schema =

  # ### 科室基本信息
  #
  #   1. ! **科室编号**（科室检查结果保存时生成）；
  #   2. ! **科室名称**（科室检查结果保存时生成）；
  #   3.   **正常小结**（临床医生工作站保存时，如无症状，存在该键，医生可以从多种小结
  #   中选择一种；检验科室在导入时根据是否存在异常设置该键）；
  #   4. 到场日期（检索某日某科室到场客人时用）。
  _id      : ObjectId
  name     : String
  # TODO: [物理检查|实验室检查]
  category : {type: String, enum: ['clinic', 'laboratory', 'radiology']}
  # TODO: 这个键需要么?
  appeared : String
  status   : {type: String, enum: ['未到场', '未付费', '未完成', '延期', '放弃', '已上机未完成', '待检验', '待审核', '已完成']}

  # ### 检查信息
  #
  # 纪录该科室初次检查情况，包括：
  # 
  #   1. 开始检查时间
  #   2. 结束检查时间
  checking :
    start    : event
    finished : event
  
  # ### 检查项目
  items : [item_schema]

department_schema = new Schema(department_schema)

department_schema.set 'toJSON', { getters: true, virtuals: true }

department_schema.virtual('is_lis_department').get () ->
  if @name in ['生化检验'] then on else off

# 根据不同的科室名称匹配所需样本。
department_schema.virtual('required_samplings').get ->
  required_samplings =
    if      @name.match /生化/               then ["黄色采血管（1）"]
    else if @name.match /免疫/               then ["黄色采血管（2）"]
    else if @name.match /过敏源/             then ["黄色采血管（3）"]
    else if @name.match /血常规/             then ["紫色采血管（1）"]
    else if @name.match /血流变/             then ["绿色采血管（1）"]
    else if @name.match /全血微量元素/       then ["绿色采血管（2）"]
    else if @name.match /血型/               then ["紫色采血管（1）"]
    else if @name.match /血沉/               then ["黑色采血管"]
    else if @name.match /凝血/               then ["蓝色采血管"]
    else if @name.match /尿常规/             then ["尿杯"]
    else if @name.match /便常规/             then ["便盒"]
    else if @name.match /便[潜隐]血/         then ['便管']
    else if @name.match /(宫颈.*细胞学|TCT)/ then ["TCT标本"]
    else if @name.match /宫颈刮片/           then ["宫颈刮片"]
    else if @name.match /白带常规/           then ["白带常规"]
    else if @name.match /心电图/             then ["心电图"]
    #else if @name.match /放射/               then ["放射科影像"]
    # else if @name.match /人乳头瘤病毒/       then ["样本"]
    else if @name.match /咽拭子/             then ["咽拭子"]
    else if @name.match /尿早早孕检测/       then ["尿早早孕检测"]
    else []
  if @name is '生化检验' and @items.some((i) -> i.name is "糖化血红蛋白") and "紫色采血管（1）" not in required_samplings
    if @items.length is 1
      required_samplings = ['紫色采血管（1）']
    else
      required_samplings.push "紫色采血管（1）"
  required_samplings

department_schema.methods.touch = () ->
  @touched = on if @is_lis_department

department_schema.methods.set_item = (item) ->
  original_department = @ownerDocument().model('Department').cached_departments_hash[@_id]
  original_item = original_department.items_hash[item.name.toUpperCase()]
  found_item    = _.find @items, (r_item) ->
    names = r_item.byname?.map((name) -> name.toUpperCase()) or []
    # 4月15号可以将此句删除
    r_item.name = '超声骨密度' if r_item.name is '骨密度'
    names.push r_item.name.toUpperCase()
    names.push r_item.abbr?.toUpperCase() if r_item.abbr
    names.some((name) -> item.name.toUpperCase() is name)
  return 0 unless original_item and found_item
  #if item?.images?.length
  # record = @ownerDocument()
  # record.images = record.images.filter (img) -> img.tag isnt item.images[0].tag
  # for image in item.images
  #   record.images.addToSet image
  found_item.set_item @, item, original_item
  #@update_calculated_item original_department
  @touch()
  1
#item.name.toUpperCase() in names

department_schema.methods.update_status = (status) ->
  for item in @items
    item.status = status if item.status in ['未完成', '延期', '放弃']

# 运算科室中有项目表达式的项目，并添加到档案科室中
department_schema.methods.update_calculated_item = (original_department)->
  for original_item in original_department.expression_items
    item = _.find @items, (item) -> item.name is original_item.name
    continue unless item
    item.set_item @, {name: item.name, expression: original_item.expression}, original_item

module.exports = department_schema
