# 修改订单付费状态为事后付费
#
# ## 
#   + **资源地址**
#   + `/records/:barcode/orders/:itemid`
#   + **例**
#     * 【添加新增项】
#     *  /records/10000001/orders/:21342101452135
# ## 数据服务（应用于修改付费状态为事后付费）
#   + 根据档案编号查询档案
#   + 添加修改项成功后返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.put '/records/:barcode/orders/:itemid', authorize('cashier'), (req, res) ->
  {barcode, itemid} = req.params
  {Record} = req.models
  do update_order = ->
    Record.barcode barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 400 unless record
      record.updator = req.event
      order = record.orders.id itemid
      order.name  = req.body.name
      order.price = req.body.price
      order.paid  = req.body.paid
      record.add_order order, (error) ->
        return res.send 500, error.stack if error
        record.save (error) ->
          return update_order() if error instanceof mongoose.Error.VersionError
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
