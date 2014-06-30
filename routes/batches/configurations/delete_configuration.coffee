# 删除指定批次下的小套餐的组合项
#
# ##  删除指定批次下的小套餐的组合项
#   + **资源地址**
#   + `/batches/:batch_id/configurations/:configuration_id`
#   + **例**
#   + `/batches/123456/configurations/456789`
#   + **例**
# ## 数据服务（应用于删除指定批次下的小套餐的组合项）
#   + 根据条件查询数据
#   + 删除成功返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.delete '/batches/:batch_id/configurations/:configuration_id', authorize('admin'), (req, res) ->
  {batch_id, configuration_id} = req.params
  pattern = /[0-9a-f]{24}/
  return res.send 404 if not batch_id?.match(pattern) or not configuration_id?.match(pattern)
  {Record, Product} = req.models
  Record.find()
  .where('profile.batch').equals(batch_id)
  .where('orders._id').equals(configuration_id)
  .select("_id")
  .exec (error, records) ->
    return res.send 500, error.stack if error
    return res.send 404 if records.length
    do delete_configuration = ->
      Product.findOne({ batch: batch_id})
      .where('configurations._id').equals(configuration_id)
      #.select("configurations")
      .exec (error, product) ->
        return res.send 500, error.stack if error
        return res.send 404 unless product
        product.configurations.remove product.configurations.id configuration_id
        product.save (error, product) ->
          return delete_configuration() if error instanceof mongoose.Error.VersionError
          return res.send 500, error.stack if error
          res.send {}

