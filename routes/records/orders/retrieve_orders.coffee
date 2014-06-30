# 根据档案编号或者barcode查询订单
#
# ## 获取的客人订单信息
#   + **资源地址**
#   + `/records/:barcode/orders`
#     * `id`：档案编号或者25条码编号
#   + **例**
#     * /records/00000003/orders
#   + **返回数据**
#     [
#        {
#         "_id": "300000000000000000000018",
#         "name": "小组合18（女）",
#         "category": "combo",
#         "paid": 2,
#         "price": 300
#        }
#     ]
# ## 数据服务（应用于付费页面客人订单信息查询）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404

app.get '/records/:barcode/orders', authorize('cashier', 'admin'), (req, res) ->
  req.models.Record.findOne(barcode: req.params.barcode)
  .select('orders')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    res.send record.orders.filter((order) -> order.paid isnt -1)
