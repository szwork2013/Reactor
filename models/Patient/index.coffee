mongoose   = require 'mongoose'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

sms_schema =
  date: String
  body: String
  tags: [String]

sms_schema = new Schema sms_schema

patient_schema =

  # 0. 生日🎂++性别+姓名
  # 1. 症状
  # 2. 短信内容
  # 3. 最后一次体检日期
  # 4. 体检次数
  _id: ObjectId
  key: String
  tags:[String]
  sms: [sms_schema]
  last_check_date: String
  checkup_count: Number

patient_schema = new Schema patient_schema, {versionKey: off, id: off, _id: off}

module.exports = patient_schema
