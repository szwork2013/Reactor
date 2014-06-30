# 给批次下某小套餐添加新组合项
#
# ##  给指定批次下的某小套餐添加新组合项
#   + **资源地址**
#   + `/batches/:batch_id/configurations/:configuration_id/combos`
#   + `req.body`
#     {
#       combo: '0123456789'
#     }
#
# ## 数据服务（应用于给指定批次下的某小套餐添加新组合项）
#   + 根据条件查询数据
#   + 添加新组合项成功返回{}，失败发送错误信息。
mongoose = require 'mongoose'

app.post '/batches/:batch_id/configurations/:configuration_id/combos', authorize('admin'), (req, res) ->
  {batch_id, configuration_id} = req.params
  pattern = /[0-9a-f]{24}/
  return res.send 404 if not batch_id?.match(pattern) or not configuration_id?.match(pattern)
  return res.send 404 unless req.body.combo?.match(pattern)
  {Product} = req.models
  do add_combo = ->
    Product.findOne({ batch: batch_id})
    .where('configurations._id').equals(configuration_id)
    .exec (error, product) ->
      return res.send 500, error.stack if error
      return res.send 404 unless product
      configuration = product.configurations.id configuration_id
      configuration.combos.addToSet  req.body.combo
      product.save (error, product) ->
        return add_combo() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
