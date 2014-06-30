mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
event    = require "../../Shared/event.coffee"

history_schema =
  user_id: String
  name: String
  date_number: Number
  date_string: String
  paid: {type: Number, enum: [-1, 0, 1, 2, 3]}
  price: Number

history_schema = new Schema(history_schema, {versionKey: off, id: off})

# 套餐或组合项（用于确定待查项目，同时作为前台与收款的桥梁）
# paid（-1：取消订单、0：未付费、1：已付费、2：事后结算，记账、3：免费）
# 1. 如果对paid为0或2的套餐进行修改，先删掉原套餐，然后新增新套餐
# 2. 如果对paid为1的套餐进行修改，向orders新增一个对象，状态为0或2，与所在位置无关。
#    在收款台退费时，将旧套餐删除；付费时，对新套餐更新状态和金额。并且更新已检查科室状态和档案完成状态
order_schema =

  # ### 订单记录

  #   1. 小套餐编号或小组合编号（注册时生成）(一份健康档案中不能包含重复的小套餐或小组合)
  #   2. 大套餐名称（小套餐名称）或大组合名称（小组合名称）（注册时生成）
  #   3. 类型[package|combo]
  #   4. 付费状态（注册时生成、付费时修改）（团检套餐注册时本键为2，部门为家属自费本键和个人注册为0）
  #   5. 单价（注册时生成）
  #   6. 现金支付金额
  #   7. 银行卡支付金额
  #   8. 套餐卡支付金额
  #   9. 会员卡支付金额
  #   10. 团购号
  #   11. 最终金额
  #   12.是否已开发票

  _id: ObjectId
  name: String
  category: {type: String, enum: ['package', 'combo']}
  paid: {type: Number, enum: [-1, 0, 1, 2, 3]}
  price: Number
  actual_price: Number
  histories: [history_schema]

order_schema = new Schema(order_schema, {versionKey: off, id: off})

#order_schema.pre 'save', (done) ->
# @price = undefined if @paid is 2
# done()

module.exports = order_schema
