# 查询指定批次下的套餐
#
# ## 获取套餐信息
#   + **资源地址**
#   + `/batches/:batch_id/configurations`
#   + **例**
#     * 根据批次编号查询套餐
#     [
#      {
#       "name": "35岁以下男宾",
#       "sex": "male",
#       "age_ut": 35,
#       "discount_price": 250,
#       "price": 300,
#       "combos": ["6e5bb37258200ed9aabc8d01"]
#       "items": ["2e5bb37258200ed9aabc8d04"]
#       "count": 5
#      }
#     ]
# ## 数据服务（应用于查找某批次下的套餐）
#   + 根据条件查询数据
#   + 查询成功返回套餐数组，失败发送错误信息。
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId

app.get '/batches/:batch_id/configurations', authorize('admin'), (req, res) ->
  {batch_id} = req.params
  return res.send 404 if not batch_id?.match /[0-9a-f]{24}/
  {Product, Record} = req.models
  Product.findOne({ batch: batch_id}).select("configurations")
  .exec (error, product) ->
    return res.send 500, error.stack if error
    return res.send 404 unless product
    configurations = product.toJSON().configurations
    commands = []
    commands.push 
      '$match': 
        'profile.batch': ObjectId batch_id
    commands.push
      '$project': 
        '_id': 0
        'orders': 1
    commands.push
      '$unwind': '$orders'
    commands.push
      '$match':
        'orders.category': 'package'
    commands.push
      '$project':
        _id: '$orders._id'
    commands.push
      '$group':
        _id: '$_id'
        count:
          $sum: 1
    Record.aggregate commands, (error, results) ->
      return res.send 500, error.stack if error
      result = results?.reduce (memo, item) ->
        memo[item._id] = item.count
        memo
      , {}
      for configuration in configurations
        configuration.count = result[configuration._id] or 0
      res.send configurations
