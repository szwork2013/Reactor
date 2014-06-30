mongoose = require 'mongoose'
moment   = require 'moment'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId

# 收款台员工可以为客人开具已付款项目发票。储值卡与套餐卡消费均不在开票范围内。
invoice_schema =
  # 发票记录条目包括：
  #
  #   1. 发票金额
  #   2. 开票日期
  #   3. 员工（编号与姓名）
  amount: Number
  date: {type: String, default:() -> moment().format('YYYY-MM-DD')}
  staff:
    _id: ObjectId
    name: String

invoice_schema = new Schema invoice_schema

module.exports = invoice_schema
