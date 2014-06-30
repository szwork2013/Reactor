# 删除指定批次下的小套餐的组合项
#
# ##  删除指定批次下的小套餐的组合项
#   + **资源地址**
#   + `/batches/:batch_id/configurations/:configuration_id/combos/:combo_id`
# ## 数据服务（应用于删除指定批次下的小套餐的组合项）
#   + 根据条件查询数据
#   + 删除成功返回{}，失败发送错误信息。
mongoose = require 'mongoose'

app.delete '/batches/:batch_id/configurations/:configuration_id/combos/:combo_id', authorize('admin'), (req, res) ->
  {batch_id, configuration_id, combo_id} = req.params
  pattern = /[0-9a-f]{24}/
  return res.send 404 unless batch_id?.match pattern
  return res.send 404 unless configuration_id?.match pattern
  return res.send 404 unless combo_id?.match pattern
  {Product} = req.models
  do delete_combo = ->
    Product.findOne({ batch: batch_id})
    .where('configurations._id').equals(configuration_id)
    .where('configurations.combos').equals(combo_id)
    .exec (error, product) ->
      return res.send 500, error.stack if error
      return res.send 404 unless product
      configuration = product.configurations.id configuration_id
      configuration.combos.remove combo_id
      product.save (error, product) ->
        return delete_combo() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
