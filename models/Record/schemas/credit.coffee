# Author: Baoshan Sheng
moment = require 'moment'
{Schema} = require 'mongoose'
{ObjectId} = Schema

# ## 记退账目
module.exports = schema = new Schema

  # + **账目类型**：`记账`或`退账`；
  # + **产品编号**；
  # + **产品名称**；
  # + **产品价格**；
  # + **发生日期**。
  type       : type: String, enum: ['记账', '退账']
  product_id : ObjectId
  name       : String
  price      : Number
  date       : type: String, index: on, default: -> moment().format('YYYY-MM-DD')
,
  _id : off
  id  : off
