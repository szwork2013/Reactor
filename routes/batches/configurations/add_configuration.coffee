# 给批次添加小套餐
#
# ## 获取套餐信息
#   + **资源地址**
#   + `/batches/:batch/configurations`
#   + **例**
#     * 根据批次编号添加小套餐
#     {
#       "name": "35岁以下男宾",
#       "sex": "male",
#       "age_ut": 35,
#       "discount_price": 250,
#       "price": 300,
#       "combos": ["6e5bb37258200ed9aabc8d01"]
#     }
# ## 数据服务（应用于查找某批次下的套餐）
#   + 根据条件查询数据
#   + 查询成功返回套餐`pac`，失败发送错误信息。
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId

app.post '/batches/:batch_id/configurations', authorize('admin'), (req, res) ->
  {batch_id} = req.params
  return res.send 404 if not batch_id?.match(/[0-9a-f]{24}/)
  configuration = {}
  (if value then configuration[key] = value) for key, value of req.body
  do add_configuration = ->
    req.models.Product.findOne({ batch: batch_id})#.select("configurations")
    .exec (error, product) ->
      return res.send 500, error.stack if error
      return res.send 404 unless product
      configuration._id = new ObjectId
      console.log configuration, 'configuration'
      product.configurations.addToSet configuration
      product.save (error, product) ->
        return add_configuration() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {_id: configuration._id}
