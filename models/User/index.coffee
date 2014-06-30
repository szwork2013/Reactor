mongoose   = require 'mongoose'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

schema =

  # 0. 用户编号
  # 1. 用户姓名
  # 2. 员工卡号
  # 3. 性别
  # 4. 密码
  # 5. 手机号码
  # 6. 电子邮箱

  _id: ObjectId
  name: String
  barcode: String
  sex: String
  pwd: String
  telephone: String
  mobile: String
  email: String

  # 职称
  position: {type: String, enum: ['主治医生', '副主任医生', '主任医生']}

  # 所属应用['检查', '前台', '收银', '团体', '套餐', '采血', '生化', '免疫', '血常规']
  apps: [String]

  # 所属权限组['护士', '医生', '检验', '客服', '运营', '管理员']
  roles: [String]

  # 医生所负责科室
  departments: [String]

  # 放射科诊断部位
  radiology_diagnosis_parts: [String]

user_schema = new Schema schema

user_schema.statics.authenticate = (user, cb) ->
  return cb() unless user
  {_id, pwd} = user
  cond = [
    (name: _id)
    (barcode: _id)
    (email: _id)
    (mobile: _id)
  ]
  @findOne()
  .where('pwd').equals(pwd)
  .or(cond)
  .exec cb

user_schema.statics.id = (id, cb) ->
  @findOne({_id: id})
  .select('name mobile telephone email radiology_diagnosis_parts')
  .exec cb

module.exports = user_schema
