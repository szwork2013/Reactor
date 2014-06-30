# 删除订单信息
#
# ## 删除项
#   + **资源地址**
#   + `/records/:barcode/orders/:itemid`
#   + **例**
#     * 【删除订单项】
#     *  /records/10000001/orders/5e5bb37258200ed9aabc8d04
# ## 数据服务（应用于删除订单项信息）
#   + 根据档案编号查询档案
#   + 删除订单项成功后返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.delete '/records/:barcode/orders/:itemid', authorize('cashier')
, (req, res) ->
  do delete_order = ->
    req.models.Record.barcode req.params.barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 400 unless record
      order = record.orders.id(req.params.itemid)
      return res.send 400 unless order
      record.delete_order order, (error) ->
        return res.send 500, error.stack if error
        record.updator = req.event
        record.save (error) ->
          return delete_order() if error instanceof mongoose.Error.VersionError
          return res.send 500, error.stack if error
          res.send {}
