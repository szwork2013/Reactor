mongoose = require 'mongoose'
moment   = require 'moment'
_        = require 'underscore'

Schema   = mongoose.Schema
ObjectId = Schema.ObjectId

event             = require "../Shared/event.coffee"
lis_event         = require "../Shared/lis_event.coffee"
order_schema      = require "./schemas/order.coffee"
invoice_schema    = require "./schemas/invoice.coffee"
credit_schema     = require "./schemas/credit.coffee"
stop_schema       = require './schemas/stop.coffee'
payment_schema    = require "./schemas/payment.coffee"
department_schema = require "./schemas/department.coffee"
sampling_schema   = require "./schemas/sampling.coffee"
suggestion_schema = require "./schemas/suggestion.coffee"
image_schema      = require "./schemas/image.coffee"
doctor_check_time_schema = require "./schemas/doctor_check_time.coffee"

# ## 健康档案建模
record_schema =

  # ### 反应堆管理
  #
  # 1. （8位交错25）**条码号**
  # 2. 客户标识符（复合键，如：`1988-08-08|女|客人甲`），在姓名、性别、出生日期完整时设置，否则反置。
  # 3. 套餐检查预设路线
  barcode: String
  customer_key: String
  customer_key1: String
  customer_key2: String
  route: {type: ObjectId, ref: 'Route'}
  sms_sent: Number
  paper_report: Boolean
  sms_review_notice: Boolean
  guidance_card_hash: String
  status: {type: String, enum: ['未付费', '未到场', '检查中', '延期', '已离场', '已完成', '已发电子报告', '已打印']}

  # ### 客人基本信息
  #
  # 在注册时，客户端负责提交客人基本信息，包括：
  #
  #   1. ! **姓名**。（服务器保证存在汉字的姓名无空格，TRIM后长度大于零）。
  #   2. ! **性别**。有限集字符串，允许取值范围：`male`、`female`。修改性别时，服务器将自动删除全部仅适用于异性的检查项目，并删除不包含任何项目的空科室。
  #   3. ! **年龄**。有效格式为0至122的任意数字。
  #   4. **证件号码**。服务器对证件号码进行处理，保证无空格。有效格式为TRIM后长度大于零的任意字符串。
  #   5. **预约日期与时间**。包括日期（`2046-11-11`）与时段（`A`、`B`、`C`、`D`、`E`）。
  #   6. **电话**。有效格式为TRIM后长度大于零的任意字符串。
  #   7. **备注**。字符串数组，用于在不同业务环节调整处理规则。
  #   8. **快递地址**。包括**收件人**（允许指定客人以外的收件人）、**电话**、**邮编**、**详细地址**。
  #   9. **团检编号**。客户端负责提供。
  #   10. **部门名称**。用于团检报告打印时填充部门名称，仅限团检客人。
  #   11. @ **来源**。公司名称或`个检`。
  #   12. @ **姓名拼音**。（服务器全程自动同步的字符串数组，考虑多音字）。

  profile:

    name: String
    sex: {type: String, enum: ['男', '女']}
    age: {type: Number, min: 0, max: 120, default: null}
    id:  {type: String, default: null, uppercase: on, trim: on}
    tel: {type: String, trim: true, default: null}
    batch: {type: ObjectId, ref: 'Batch'}
    division: {type: String, default: null}
    check_date: {type: String, default: null}
    check_time: {type: String, enum: ['A', 'B', 'C', 'D', 'E', null, ''], default: null}
    tel: {type: String, trim: true, default: null}
    notes: [String]
    ship_to: {type: String, default: null}
    id_card_verified: {type: Boolean, default: null}


    source: String
    name_pinyin: [String]
    live_portrait: ObjectId
    hash_id: {type: String, default: null}
   
  doctor_check_time: [doctor_check_time_schema]
  guidance_card_printed: {type: Boolean, default: off}
  change_date: String
  non_empty: {type: Boolean, default: off}

  # ## 到场日期
  # 适用场景包括：
  #
  #   1. 状态条显示；
  #   2. 医生工作站统计该科室未查人数（全部本日到场客人中该科室未检查者）。
  appeared: [String]

  # 完成临床检验和采样
  field_complete: event

  # ## 全部检查完成时间
  # 适用场景包括：
  #
  #   1. 状态条显示；
  #   2. 总检需要根据此键进行派发。
  #     1. 科室检查保存（同步更新该科室、档案完成状态）
  #     2. 实验室检查结果导入（同步更新该科室、档案完成状态）
  #     3. 前台订单修改时(新增一个付款状态为2的套餐组合时、或者删除付款状态不为0的套餐组合时)（同步更新全部科室、档案完成状态）
  #     4. 通过付款API导致的订单修改（同步更新全部科室、档案完成状态）
  #     5. 套餐组合修改时（同步更新所波及的档案的全部科室、档案完成状态）
  # 均需要同步更新本键。
  #
  # 持久化全部检查完成时间对派发服务的算法复杂度有几何级改进。
  report_complete: event

  # 总检模式[自动|人工]
  inspection_mode: {type: String, enum: ['自动', '人工']}

  # 是否生成pdf
  pdf_created: Boolean
  
  # 打印完成时间
  printed_complete: event

  # 打印次数
  print_counter: {type: Number, default: 0}

  # 同意签署协议书
  hbv_agreement_signed: {type: Boolean, default: off}

  # 影像
  images: [image_schema]

  # 生化检验
  # 1. 盘+孔
  # 2. 上机操作标识
  # 3. 审核信息
  biochemistry : lis_event
  hematology   : lis_event
  immunoassay  : lis_event

  # 生化状态
  biochemistry_status: String

  #  disk_and_position: String
  #  analyze_start: Date
  #  audit: event

  # ## 总检派发时间

  # 向医生派发总检后设置该键（在超时续约时验证此键）。总检结束后，删除此键。
  dispatched: Date

  # ## 总检完成

  # 在总检完成后，向健康档案增补总检对象（无论由机器自动总检，或者由医生总检，
  # 均在总检后增补该对象），包括：
  #
  #   1. **总检时间**；
  #   2. **总检医生**（自动总检的健康档案无此对象）。
  #
  # 统计总检医生工作量时应用本部分数据。
  approval: event

  # ## @ ! 注册信息

  # 文档创建时，服务器增补注册信息，包括：
  #
  #   1. **注册时间**；
  #   2. **注册人**（编号与姓名）。
  #
  # 本部分亦作销售绩效统计用（销售与前台均有权限登陆注册UI，或者销售UI使用相同API进行注册）。
  registration: event
 
  # ## 修改信息
  # 文档的基本信息或订单在前台被修改时，包括：
  #
  #  1. **修改时间**;
  #  2. **修改人**（编号与姓名）。
  updator: event

  # ## 快递信息

  # 以下健康档案由经快递：
  #
  #   1. 类型为`个人`，且（无`自取`备注，或，无`交工作人员`备注）；
  #   2. 类型为`团体`，且有`快递`备注。
  #
  # 对于由经快递的健康档案，在报告装配后生成快递信息对象，包括：
  #
  #   1. **承运公司**（编号与姓名）；
  #   2. **追踪单号**。
  #
  # 后台进程轮询未签收的快递单，及时增补以下两个键：
  #
  #   1. **承运公司名称**;
  #   2. **取件时间**；
  #   3. **签收时间**。
  #
  # _提前安排与快递公司签合约，获取查询API接口认证。_
  express:
    courier: String
    tracking_number: String
    picked_up: Date
    delivered: Date

  # ## 档案内容
  #
  # 1. 订单内容
  # 2. 付款记录
  # 3. 发票记录
  # 4. 采样记录
  # 5. 检查（检验）结果
  # 6. 总检结论

  orders      : [order_schema]
  payments    : [payment_schema]
  credits     : [credit_schema]
  stops       : [stop_schema]
  invoices    : [invoice_schema]
  samplings   : [sampling_schema]
  departments : [department_schema]
  suggestions : [suggestion_schema]

  # ## @ ! 文档版本

  # 避免并发修改该文档时的竞争隐患。
  # Mongoose框架Versioning策略。
  __v: Number


record_schema = new Schema(record_schema, {versionKey: 'myVersionKey', id: off})

# ## 索引定义及应用场景。

# 拍打身份证检索客人信息
record_schema.index
  'profile.name': 1
  'profile.sex': 1
  'profile.id': 1

record_schema.index
  'samplings.sampled.date_string': 1

record_schema.index
  'status': 1

record_schema.index
  'biochemistry_status': 1

record_schema.index
  'field_complete.date_string': 1

record_schema.index
  'non_empty': 1

record_schema.index
  'samplings.status': 1

record_schema.index
  'samplings.biochemistry': 1

record_schema.index
  'departments.name': 1

record_schema.index
  'departments.status': 1

record_schema.index
  'profile.name': 1

record_schema.index
  'profile.name_pinyin': 1

record_schema.index
  'profile.id': 1

record_schema.index
  'profile.tel': 1

record_schema.index
  'profile.check_date': 1

record_schema.index
  'profile.batch': 1

record_schema.index
  'profile.division': 1

record_schema.index
  'registration.date': 1

record_schema.index
  'barcode': 1

record_schema.index
  'biochemistry.audit.date_string': 1

record_schema.index
  'profile.notes': 1

# 检查日期验证
record_schema.path('profile.check_date').validate (v) ->
  return moment(v).isValid()
, '无效的检查日期'

# 身份证号验证
record_schema.path('profile.id').validate (v) ->
  require("./validators/id.coffee")(v)
, '无效的身份证编号或者无效的出生日期'

# 电话号码验证
# 有效的移动电话或固话（7或8位可配置）（可能含区号或分机号）
record_schema.path('profile.tel').validate (v) ->
  require("./validators/tel.coffee")(v)
, '无效的移动电话或固话'

# 验证整数年龄
record_schema.path('profile.age').validate (v) ->
  return not v or v is ~~v
, '无效的0至120之间的整数年龄'

# TODO: 开启SaaS模式之前，允许各健检中心独立配置忽略科室。
record_schema.statics.ignore_departments = ->
  [
    # 忽略离场之后完成录入的临床科室
    '身高体重'
    '血压'
    '腰臀比'
    '体脂率'
    # 忽略难以标记真实采样情况的科室
    'C13幽门螺旋杆菌检测'
    '尿常规'
    '便潜血'
    '便常规'
    '冲击波筛查'
  ]

record_schema.statics.required_samplings = ->
  '生化检验': '黄色采血管（1）'
  '免疫检验': '黄色采血管（2）'
  '过敏源': '黄色采血管（3）'
  '血常规': '紫色采血管（1）'
  '血流变': '绿色采血管（1）'
  '全血微量元素': '绿色采血管（2）'
  '血型': '紫色采血管（1）'
  '血沉': '黑色采血管'
  '凝血': '蓝色采血管'
  '尿常规': '尿杯'
  '便常规': '便盒'
  '便潜血': '便管'
  '宫颈超薄细胞学检查': 'TCT标本'
  '宫颈刮片': '宫颈刮片'
  '白带常规': '白带常规'
  '心电图': '心电图'
  '咽拭子': '咽拭子'
  '尿早早孕检测': '尿早早孕检测'

# 未完成科室列表
record_schema.virtual('unfinished_departments').get () ->
  # TODO: 进一步评估必要性。
  return [] unless @departments
  departments = JSON.parse JSON.stringify @departments.map (d) -> d.toJSON()
  ignore_departments = @model('Record').ignore_departments()
  departments = departments.filter (d) ->
    (d.name is '放射科' and d.status in ['未完成', '待检验']) or \
    (d.status in  ['未完成', '放弃', '延期'] and d.name not in ignore_departments)
  for department in departments
    department.unfinished_items or = []
    every_unfinished = department.items.every (item) -> item.status is '未完成'
    if department.status is '未完成' and not every_unfinished
      department.unfinished_items = department.items
        .filter((item) -> item.status is '未完成')
        .map((item) -> item.name)
    if department.status is '待检验'
      department.unfinished_items = department.items
        .filter((item) => not @images.some((image) -> image.tag?.match(item.name?.match(/胸部|颈椎|腰椎/))))
        .map((item) -> item.name)
    department.schedule_items or = []
    every_scheduled = department.items.every (item) -> item.status is '延期'
    if department.status is '延期' and not every_scheduled
      department.schedule_items = department.items
        .filter((item) -> item.status is '延期')
        .map((item) -> item.name)
    if (department.required_samplings.some (s) -> s.match /采血/)
      department.name = '采血'
  # TODO: 不加这个或判断，程序会出异常。
  # /records?keywords=wy&filter=%20profile,departments&department_names=%E7%94%9F%E5%8C%96%E6%A3%80%E9%AA%8C
  samplings = (@samplings or []).filter (s) ->
    s.name.match(/采血/) and s.status in ['未采样']
  sampled   = (@samplings or []).some (s) ->
    s.name.match(/采血/) and s.status in ['已采样']
  unfinished_departments = for name, departments of _.groupBy departments, 'name'
    department =
      _id: departments.map((department) -> department.id).join()
      name: name
      status: departments[0].status
      unfinished_items: _.flatten (_.pluck(departments, 'unfinished_items')) or []
      schedule_items: _.flatten (_.pluck(departments, 'schedule_items')) or []
    if department.name is '采血' and sampled and samplings.length
      for sampling in samplings
        department.unfinished_items.push sampling.name + sampling.tag
    department
  unfinished_departments = unfinished_departments.filter (d) ->
    not (d.status is '待检验' and not d.unfinished_items.length)
  unfinished_departments = _.sortBy unfinished_departments, (d) -> -['采血'].indexOf(d.name)

#record_schema.path('profile.check_date').set (v) ->
  #@check_date_is_today = if not @appeared.length and @profile.check_date is moment().format('YYYY-MM-DD') then on else off
  #v
# 姓名去空格
record_schema.path('profile.name').set (v) ->
  reg = /^[\u4E00-\u9FFF\u3000\s]+$/
  if not reg.test v # 如果不全是汉字去掉左右空格
    v = v.trim()
  else # 如果全是汉字统一处理去掉所有空格
    v = v.replace /[\s\u3000]/g, ''
  v

# 身份证号去掉空格
record_schema.path('profile.id').set (v) ->
  v = v?.replace /[\s\u3000]/g, ''
  v or null

# 部门去掉空格或回车
record_schema.path('profile.division').set (v) ->
  v = v.trim() if v
  v or null

record_schema.set 'toJSON',   { getters: false, virtuals: true }

module.exports = record_schema
module.schema  = record_schema

record_schema.statics.setBirthday = (id) ->
  if id.length is 18
    return id.substr(6,4) + '-' + id.substr(10,2) + '-' + id.substr(12,2)
  else if id.length is 10
    return id

record_schema.statics.setAge = (birthday) ->
  birth = moment(birthday)
  age = moment().format('YYYY') - birthday?.split('-')[0]
  return if (birth.add("y", age) > moment()) then age - 1 else age

require "./methods"
require "./middlewares"
