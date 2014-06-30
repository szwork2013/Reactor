# 查询指定小套餐
#
# ## 获取指定小套餐信息
#   + **资源地址**
#   + `/batches/:batch_id/configurations/:configuration_id`
#   + **例**
#      {
#       "name": "35岁以下男宾",
#       "sex": "male",
#       "age_ut": 35,
#       "discount_price": 250,
#       "price": 300,
#       "combos": ["6e5bb37258200ed9aabc8d01"],
#       "items": ["2e5bb37258200ed9aabc8d04"]
#      }
# ## 数据服务（应用于查询指定小套餐）
#   + 根据条件查询数据
#   + 查询成功返回小套餐，失败发送错误信息。

app.get '/batches/:batch_id/configurations/:configuration_id', authorize('admin'), (req, res) ->
  {batch_id, configuration_id} = req.params
  pattern = /[0-9a-f]{24}/
  return res.send 404 if not batch_id?.match(pattern) or not configuration_id?.match(pattern)
  req.models.Product.findOne({ batch: batch_id})
  .where('configurations._id').equals(configuration_id)
  .select("configurations")
  .exec (error, product) ->
    return res.send 500, error.stack if error
    return res.send 404 unless product
    configurations = product.configurations.filter (c) -> String(c._id) is configuration_id
    res.send configurations[0]
