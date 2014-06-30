# 对编号查询批次
#
# ## 根据批次编号获取批次信息
#   + **资源地址**
#   + `/batches/:batch_id`
#   + **例**
#     * /batches/123456789
#      {
#        _id: '001',
#        company: "北京亿玛在线科技有限公司",
#        ......
#      }
# ## 数据服务（应用于获取单个批次）
#   + 根据条件查询数据
#   + 查询成功返回对象`batch`，失败发送错误信息。

app.get '/batches/:batch_id', authorize('mo', 'admin'), (req, res) ->
  {batch_id} = req.params
  return res.send 404 if not batch_id?.match /[0-9a-f]{24}/
  {Batch, Product} = req.models
  Batch.findById(batch_id)
  .select(req.query.fields?.replace(/,/g, ' '))
  .exec (error, batch) ->
    return res.send 500, error.stack if error
    return res.send 404 unless batch
    Product.findOne({ batch: batch_id })
    .exec (error, product) ->
      return res.send 500, error.stack if error
      batch = batch.toJSON()
      batch.name = batch.company
      batch.configurations = product.configurations
      res.send batch
