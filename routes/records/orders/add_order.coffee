# 新增订单信息
#
# ## 新增项
#   + **资源地址**
#   + `/records/:barcode/orders`
#   + **例**
#     * 【添加新增项】
#     *  /records/10000001/orders
#     * `req.body`内容分别如下：
#       {
#         _id: "5e5bb37258200ed9aabc8d04", 
#         name: '大组合2(小组合2)', 
#         category: 'combo',
#         paid: 0,
#         price: 300
#       }
# ## 数据服务（应用于追加新增项信息）
#   + 根据档案编号查询档案
#   + 添加新增项成功后返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.post '/records/:barcode/orders', authorize('cashier'), (req, res) ->
  {Record}   = req.models
  {barcode}  = req.params
  do add_order = ->
    Record.barcode barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 400 unless record
      record.event = req.event
      record.add_order req.body, (error) ->
        return res.send 500, error.stack if error
        record.updator = req.event
        record.save (error) ->
          return add_order() if error instanceof mongoose.Error.VersionError
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
                  orderids = record.orders.map (order) -> order._id
                  Record.set_paper_report barcode, orderids, (error) ->
                    console.log error if error
