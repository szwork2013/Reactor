# 修改图片tag
#
# ## 修改图片tag
#   + **资源地址**
#   + `/records/:barcode/images/:id/tag/:tag`
# ## 数据服务
#   + 修改图片


app.put '/records/:barcode/images/:id/tag/:tag', authorize('mo', 'admin'), (req, res) ->
  {barcode, id, tag} = req.params
  req.models.Record.barcode barcode, {paid_all: on}, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 400 unless record
    image = record.images.id id
    image?.tag = tag
    record.save (error) ->
      return res.send 500, error.stack if error
      res.send {}
