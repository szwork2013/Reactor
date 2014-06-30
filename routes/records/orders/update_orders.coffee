# 修改所有订单
#
# ## 
#   + **资源地址**
#   + `/records/:barcode/orders`
#   + **例**
#     * 【添加新增项】
#     *  /records/10000001/orders
# ## 数据服务（应用于所有订单）
#   + 根据档案编号查询档案
#   + 添加修改项成功后返回{}，失败发送错误信息。
mongoose = require "mongoose"
_        = require 'underscore'

app.put '/records/:barcode/orders', authorize('cashier'), (req, res) ->
  {barcode} = req.params
  {Record}  = req.models
  {_id, name, date_number, date_string} = req.event
  data =
    user_id: _id
    name: name
    date_number: date_number
    date_string: date_string
  paid_orders   = req.body.filter((order) -> order.paid in [1,3])
  unpaid_orders = req.body.filter((order) -> order.paid in [0,2])
  do update_orders = ->
    Record.barcode barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 400 unless record
      record.event = req.event
      orders  = record.orders
      maybe_del_orders = orders.filter((order) -> order.paid in [0, 3])
      # 删除订单中存在、req.body不存在的未付费和免费订单
      orders.remove orders.filter((order) -> not maybe_del_orders.some((_order) -> _order._id is order._id.toString()))...
      # 如果订单中记账的订单不在
      # req.body中则标记为取消
      orders_ = orders.filter((order) -> order.paid is 2)
      for order in orders_ when not req.body.some((order_) -> order_._id is order._id.toString())
        history = _.clone data
        history.paid = order.paid = -1
        history.price = if order.actual_price? then order.actual_price else order.price
        order.histories.push history
      # 提交的订单存在时已付费、免费订单时。 
      for order in paid_orders when not orders.id order._id
        order.histories or = []
        history = _.clone data
        history.paid  = order.paid
        history.price = if order.actual_price? then order.actual_price else order.price
        order.histories.push history
        orders.push order
      payment_items = []
      # 添加个人套餐或新增新增项
      # 修改订单信息
      for order in unpaid_orders
        if order.actual_price? and not order.actual_price
          order.paid = 1
          payment_items.push
            _id:  order._id
            name: order.name
            category: order.category
            actual_price: 0.00
        index = orders.indexOf orders.id order._id
        history = _.clone data
        history.paid  = order.paid
        history.price = if order.actual_price? then order.actual_price else order.price
        if index is -1
          order.histories = []
          order.histories.push history
          orders.push order
        else
          if order.paid isnt orders[index].paid or order.actual_price isnt orders[index].actual_price \
          or order.price isnt orders[index].price
            orders[index].histories.push history
          _.extend orders[index], order
      if payment_items.length
        payment =
          category: 'payment'
          amount: 0.00
          cash: 0.00
          authentication: req.user
          staff: req.event
          items: payment_items
        record.payments.push payment
      if unpaid_orders.some((order) -> order.actual_price)
        record.updator = req.event
      record.sync_departments (error) ->
        return res.send 500, error.stack if error
        record.biochemistry_update = on
        record.save (error) ->
          return update_orders() if error instanceof mongoose.Error.VersionError
          return res.send 500, error.stack if error
          do update_guidance_card_hash = ->
            Record.barcode barcode, (error, record) ->
              return res.send 500, error.stack if error
              return res.send 400 unless record
              record.update_guidance_card_hash (error) ->
                return res.send 500, error if error
                record.save (error) ->
                  return update_guidance_card_hash() if error instanceof mongoose.Error.VersionError
                  return res.send 500, error.stack if error
                  res.send {}
