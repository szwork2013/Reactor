# 给批次修改小套餐
#
# ## 修改小套餐
#   + **资源地址**
#   + `/batches/:batch/configurations/:configuration_id`
#   + **例**
#     * 根据批次编号和小套餐编号修改小套餐
#     {
#       "name": "35岁以下男宾",
#       "sex": "male",
#       "age_lt": 10,
#       "age_ut": 35,
#       "discount_price": 250,
#       "price": 300
#     }
# ## 数据服务（应用于修改某批次下的小套餐）
#   + 根据条件查询数据
#   + 修改成功返回{}，失败发送错误信息。
pinyin   = require '../../../utils/pinyin.coffee'

app.put '/batches/:batch_id/configurations/:configuration_id', authorize('admin'), (req, res) ->
  {batch_id, configuration_id} = req.params
  pattern = /[0-9a-f]{24}/
  return res.send 404 if not batch_id?.match(pattern) or not configuration_id?.match(pattern)
  delete req.body.combos
  delete req.body.items
  updator = {"$unset":{}}
  (if value then updator['configurations.$.' + key] = value else updator["$unset"]['configurations.$.' + key] = 1) for key, value of req.body
  updator['configurations.$.name_pinyin'] = pinyin req.body.name if req.body.name? 
  req.models.Product.update {batch: batch_id, 'configurations._id': configuration_id}
  , updator , {safe: true}, (error, numberAffected) =>
    return res.send 500, error.stack if error
    return res.send 404 unless numberAffected
    res.send {}
