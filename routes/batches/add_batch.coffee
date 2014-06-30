# 新增批次信息
#
# ## 创建批次
#   + **资源地址**
#   + `/batches`
#   + **例**
#     * `req.body` 内容分别如下：
#      {
#       "company": "物理所"
#      }
# ## 数据服务（应用于团检注册）
#   + 创建批次和套餐
#   + 新增成功返回{}，失败发送错误信息。

app.post '/batches', authorize('mo', 'admin'), (req, res) ->
  req.body.registration = req.event
  batch = new req.models.Batch req.body
  batch.save (error, batch) ->
    return res.send 500, error.stack if error
    res.send {_id: batch._id, package_id: batch.package_id}
