mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
async    = require 'async'
_        = require 'underscore'

event = require "../Shared/event.coffee"

batch_schema =

  # 批次编号
  _id: ObjectId

  # 1. 公司名称
  # 2. 状态: [提案|开放|完成|失败]
  # 3. 地址
  # 4. 联系人
  company: {type: String, required: on}
  status: {type: String, enum: ['proposal', 'ongoing', 'closed', 'failed'], default: 'proposal', required: on}
  address: String
  contact:

    # 1. 姓名
    # 2. 职务，应用程序中可进行(`chosen`)预置
    # 3. 办公电话
    # 4. 移动电话
    # 5. 电子邮件
    name: String
    job: String
    office: String
    mobile: String
    email: String

  # 方案书中预排日期：
  # 1. 9月17号与9月22号；
  # 2. 9月17号至9月22号，共6天。
  # 信息较灵活，由应用程序负责提供。
  reservation: String

  # 注册人和时间
  registration: event

  __v: Number

batch_schema = new Schema(batch_schema, {versionKey: 'myVersionKey', id: off})

batch_schema.virtual('reservation_range').get () ->
  @_reservation_range

batch_schema.virtual('reservation_range').set (v) ->
  @_reservation_range = v

# TODO: 这个虚拟键应用程序貌似木有用到?
# ??
# 新建批次时用到此键
batch_schema.virtual('package_id').get () ->
  @_package_id

batch_schema.virtual('package_id').set (v) ->
  @_package_id = v

# TODO: 使用`post save`中间件完成该工作。
# 能不能利用`mongodb/mongoose`的`upsert`机制保证公司名称始终同步?
# 降低了`router`的逻辑复杂度，同时让编码更轻松?
#
# post save 无法知道是新增批次还是修改批次
# 这里主要是为了获取到套餐编号赋给虚拟键
batch_schema.pre 'save', (next) ->
  return next() if @_id
  @_id = new mongoose.Types.ObjectId
  pac =
     _id: new mongoose.Types.ObjectId
     name: @company
     category: 'package'
     batch: @_id
  @model('Product').create pac, (error, pac) =>
    return next error if error
    @package_id = pac._id
    next()

batch_schema.statics.getProductbyBatch = (batch, cb) ->
  @model('Product').findOne()
  .where('batch').equals(batch)
  .select('name configurations._id')
  .select('batch')
  .select('configurations.sex configurations.name')
  .select('configurations.age_lt configurations.age_ut')
  .populate('batch', 'company')
  .exec (error, product) ->
    return cb error if error
    cb null, product

batch_schema.statics.get_records_by_batch = (batch, callback) ->
  @model('Record').find({'profile.batch': batch, 'sms_sent': {'$in': [null, off]}, 'profile.tel': {'$nin': ['', null]}, 'appeared': {'$ne': []}})
  .select('barcode customer_key profile.tel profile.name profile.hashid profile.check_date')
  .exec (error, records) ->
    return callback error if error
    records = records.sort (a, b) ->
      if a.profile.check_date < b.profile.check_date then 1 else -1
    tel_groups = _.groupBy records, (record) -> record.profile.tel
    results = for tel, records of tel_groups
      groups = _.groupBy records, (record) -> record.customer_key
      guests = for customer_key, records of groups
        barcode: records[0].barcode, name: records[0].profile.name, hash_id: records[0].profile.hash_id
      tel: tel, guests: guests
    callback null, results

batch_schema.statics.send_sms = (batch, callback) ->
  @model('Record')
  .find({'profile.batch': batch, appeared:{'$ne': []}, 'sms_sent': {'$in': [null, off]}})
  .select('barcode profile.tel profile.name profile.hashid profile.check_date')
  .exec (error, records) =>
    return callback error if error
    # 查询出来的有部分档案有手机号，有部分档案没手机号
    # 对没手机号的各档案调用related方法，如果档案中存在customer_key1，则从
    # 数据库中查询customer_key1等于档案中的customer_key1；或者，如果档案中
    # 存在customer_key2，则从数据库中查询customer_key2等于档案中的customer_key2；
    # 前提条件是查找有手机号的档案，并且匹配customer_key1,customer_key2的档案
    # 对于查询出来的档案，根据档案中的check_date的年份减到年龄得到出生年份，
    # 如果出生年份相差不到2岁则使用符合档案的手机号赋值给对应的没手机号的档案。
    # 保存到数据库中，将档案的手机号集合一一调用send_sms
    # record.related (error, records)
    # 查找其中customer_key1 is r.customer_key1 if customer_key1
    # 查找其中customer_key2 is r.customer_key2 if customer_key2
    records = records.filter((record) -> not record.profile.name.match(/测试/) and record.profile.tel?.length is 11)
    tels = _.uniq records.map((record) -> record.profile.tel)
    #console.log tels
    #console.log '---------------'
    tasks = tels.map (tel) => (callback) =>
      @model('Record').send_sms tel, (error, msg) =>
        return callback error if error
        if msg.split('|')[0] is '1'
          msg="ok"
        else
          msg="[号码：#{tel}发送失败，状态：#{msg}]"
        callback null, msg
    async.parallelLimit tasks, 5, (error, messages) ->
      return callback error if error
      callback null, messages

# 获取某批次下的预约日期范围
batch_schema.methods.populate_reservation_range = (callback) ->
  find_boundary_date = (direction) =>
    (callback) =>
      @model('Record')
      .find({'profile.batch': @_id})
      .select('profile.check_date')
      .sort(direction + 'profile.check_date')
      .limit(1)
      .exec(callback)
  async.parallel
    max: find_boundary_date '-'
    min: find_boundary_date ''
  , (error, data) =>
    return callback error if error
    @reservation_range =
      if not data.min[0] then ''
      else
        min_date = data.min[0]?.profile.check_date.split '-'
        max_date = data.max[0]?.profile.check_date.split '-'
        if min_date[0] isnt max_date[0]
          "#{min_date[0]}年#{min_date[1]}月至#{max_date[0]}年#{max_date[1]}月"
        else if min_date[1] isnt max_date[1]
          "#{min_date[0]}年#{min_date[1]}月至#{max_date[1]}月"
        else
          "#{min_date[0]}年#{min_date[1]}月"
    callback()

batch_schema.set 'toObject', {virtuals: true}

batch_schema.pre 'save', (callback) ->
  @increment()
  callback()

# ## 索引

# 大多数场景无需关注大量状态为`失败`的批次。因此，为`status`增加索引。
batch_schema.index
  'status': 1

# 在`团检`应用中，会根据公司名称直接搜索批次。因此，为`company`键增加索引。
batch_schema.index
  'company': 1

module.exports = batch_schema
