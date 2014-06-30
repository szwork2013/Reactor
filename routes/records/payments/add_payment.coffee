# 新增收费或退费信息
#
# ## 新增付款信息
#   + **资源地址**
#   + `/records/:barcode/payments`
#   + **例**
#     *  /records/10000002/payments
#     * `req.body`内容分别如下：
#       {
#         category: 'payment',                  //收费(payment)或退费(refund)类型
#         amount: 550,                          //付款金额
#         cash: 150                             //现金
#         transfer: 200                         //银行卡支付金额
#         authorization: {                      //授权人信息
#           _id: '0000000000000005',
#           name: '李超',
#           pwd: '123'
#         }, 
#         items: [
#           {
#             _id: '0000000000000000000001',    //小套餐或小组合编号
#             name: '小组合1',                  //小套餐或小组合名称
#             category: 'combo',
#             actual_price: 270                       //使用优惠金额后价格
#           },
#           {
#             _id: '0000000000000000000002',    //小套餐或小组合编号
#             name: '小组合2',                  //小套餐或小组合名称
#             category: 'combo',
#             actual_price: 280                       //使用折扣金额后价格
#           },
#           {
#             _id: '0000000000000000000003',    //小套餐或小组合编号
#             name: '小套餐1',                  //小套餐或小组合名称
#             category: 'package',
#             actual_price: 0                        
#           }
#           {
#             _id: '0000000000000000000004',    //小套餐或小组合编号
#             name: '小套餐2',                  //小套餐或小组合名称
#             category: 'package',
#             actual_price: 0                     
#           }
#         ]
#       }
# ## 数据服务（应用于追加付款信息）
#   + 1、验证
#   + 2、业务操作
#   + 3、订单和费用操作、保存结算信息
#   + 4、更新客人完成时间

moment = require 'moment'

app.post '/records/:barcode/payments', authorize('cashier'), (req, res) ->
  {Record}  = req.models
  {barcode} = req.params
  payment   = req.body
  Record.barcode barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 400 unless record
    {amount, cash, transfer, items} = payment
    #return res.send 403 unless amount is (items.reduce (memo, item) ->
    #  memo + (item.actual_price or 0)
    #, 0)

    {orders, payments} = record
    payment.staff = req.event

    if payment.category is 'payment'
      for payment_item in payment.items
        order_item = orders.id payment_item._id
        order_item.paid = 1
        order_item.actual_price = payment_item.actual_price
    else if payment.category is 'refund'
      for {_id} in payment.items
        orders.remove orders.id _id
    
    total_price = (items.reduce (memo, item) ->
      memo + (item.price or 0)
    , 0)

    payment.authorization = record.updator if amount isnt total_price and not payment?.authorization?._id
    record.add_payment payment, (error) ->
      return res.send 500, error.stack if error
      record.save (error, record) ->
        return res.send 500, error.stack if error
        res.send {}
