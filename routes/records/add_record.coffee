# 新增个人档案信息
#
# ## 新增个人档案
#   + **资源地址**
#   + `/records`
#   + **例**
#     * 【散客注册和团体补录档案】
#     * `req.body`内容分别如下：
#      {
#       "profile": {
#          name:'王玲',
#          sex:'female',
#          age:25
#          batch: '4e5bb37258200ed9aabc5d11'           (团体补录时有此键)
#          division:'研发部'
#          .......
#       }
#       "orders": [...]
#      }
# ## 数据服务（应用于个人注册）
#   + 新增客人档案
#   + 新增成功返回{}，失败发送错误信息。

app.post '/records', authorize('mo', 'admin'), (req, res) ->
  req.body.registration = req.event
  record = new req.models.Record req.body
  console.log 'event', JSON.stringify record.event = req.event
  record.save (error, record) ->
    console.log error, 'error'

    return res.send 500, error.stack if error
    res.send barcode: record.barcode
