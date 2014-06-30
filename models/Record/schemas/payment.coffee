mongoose = require 'mongoose'
moment   = require 'moment'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
event    = require "../../Shared/event.coffee"

# 每次付款（含退款）都向付款记录新增一个条目，再遍历该条目全部项目，如：
#
#   1. 收费类型，则对订单中相应项目的以下键进行覆盖：`paid`、`price`、`actual_price`；
#   2. 退费类型，则删除订单中对应的项目。
payment_item_schema =
  # 付款项目
  #
  # 付款项目包括：
  #   1. 小套餐编号或小组合编号（注册时生成）(一份健康档案中不能包含重复的小套餐或小组合)
  #   2. 大套餐名称（小套餐名称）或大组合名称（小组合名称）（注册时生成）
  #   3. 项目类型
  #   4. 项目原价
  #   5. 实际金额（收费和退款均存在）
  _id: ObjectId
  name: String
  category: {type: String, enum: ['package', 'combo']}
  price: Number
  actual_price: Number

payment_item_schema = new Schema(payment_item_schema, {versionKey: off, id: off})

payment_schema =
  # 付款记录条目结构为：
  #
  #   1. **类型**：(收费payment和退款refund) 
  #   2. **付款金额**：数字类型；
  #   3. **现金支付金额**：不适用时无此键；
  #   4. **银行卡支付金额**：不适用时无此键；
  #   5. **授权人信息**
  #   6. **收费人和收费时间**
  #   7. **付款项目**
  category: {type: String, enum: ['payment', 'refund']}
  amount: Number
  cash: Number
  transfer: Number
  authorization:
    _id: ObjectId
    name: String
  staff: event
  items: [payment_item_schema]

payment_schema = new Schema(payment_schema, {versionKey: off, id: off})

payment_schema.index
  'payments.staff.date_string': 1

module.exports = payment_schema

