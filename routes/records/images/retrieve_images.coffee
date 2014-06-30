# 读取图片
#
# ## 读取图片
#   + **资源地址**
#   + `/records/:barcode/images`
# ## 数据服务
#   + 读取图片


app.get '/records/:barcode/images', authorize('mo', 'admin'), (req, res) ->
  req.models.Record.findOne(barcode: req.params.barcode)
  .select('images')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 400 unless record
    res.send record.images
