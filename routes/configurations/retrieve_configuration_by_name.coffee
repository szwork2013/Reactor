
# ## 数据服务（应用于配置信息查询）
#   + 根据条件查询数据
#   + 查询成功返回对象`content`，失败发送错误信息。

app.get '/configurations/:name', authorize('cashier'), (req, res) ->
  content = req.models.Configuration[req.params.name]
  return res.send 404 unless content
  res.send content
