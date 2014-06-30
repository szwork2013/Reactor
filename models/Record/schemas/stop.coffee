moment = require 'moment'
{Schema} = require 'mongoose'
{ObjectId} = Schema

# 客人每站检查信息
#
# + 服务员工编号；
# + 服务员工姓名；
# + 服务起始时间；
# + 服务结束时间；
# + 服务结束日期。
module.exports = schema = new Schema
  user_id   : ObjectId
  user_name : String
  start     : Number
  action    : String # `采血`、`内科检查`、`腹部超声、乳腺超声检查`、`胸部正位片`
  end       : type: Number, default: Date.now
  date      : type: String, default: (-> moment().format('YYYY-MM-DD')), index: on
,
  _id: off
  id: off

# 客人各站检查信息数组调整位置：
#
# 1. 科室保存接口：`/routes/records/departments`；
# 2. 样本采样接口：`/routes/records/samplings`；
# 3. 放射影像上传：`/routes/records/images`；
# 4. 骨密度保存时：`/routes/records/imports`。TODO: 考虑删除该接口。
