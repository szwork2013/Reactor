# 根据批次查询客人档案
#
# ## 查询客人档案
#   + **资源地址**
#   + `/batches/:batch_id/records`
#
# ## 数据服务（应用于查询某批次下的客人档案）
#   + 查询客人档案
#   + 查询成功返回{}，失败发送错误信息。

app.get '/batches/:batch_id/records', authorize('mo', 'admin'), (req, res) ->
  query = req.models.Record.find()
  .where('profile.batch').equals(req.params.batch_id)
  query.skip(req.query.skip) if req.query.skip
  query.limit(req.query.limit) if req.query.limit
  query.select(req.query.fields?.replace(/,/g, ' '))
  .exec (error, records) ->
    return res.send 500, error.stack if error
    res.send records
