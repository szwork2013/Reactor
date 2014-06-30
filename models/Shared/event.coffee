mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

module.exports =
  # 采样时间毫秒值(采样时距1970年始之间的毫秒差)
  date_number: Number
  
  # 采样时间,格式:XXXX-XX-XX
  date_string: String
  
  # 采样者编号
  # TODO: 改键名为user_id
  user_id: ObjectId
  
  # 采样者姓名
  # TODO: 改键名为user_name
  user_name: String
