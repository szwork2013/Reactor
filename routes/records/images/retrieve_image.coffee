# 读取图片
#
# ## 读取图片
#   + **资源地址**
#   + `/records/:barcode/images/:image.jpeg`
# ## 数据服务
#   + 读取图片


app.get '/records/:barcode/images/:image', authorize('mo', 'admin'), (req, res) ->
  {Record} = req.models
  image    = req.params.image
  Record.barcode req.params.barcode, {paid_all: on}, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 400 unless record
    res.sendfile("./public/images/#{image}")
