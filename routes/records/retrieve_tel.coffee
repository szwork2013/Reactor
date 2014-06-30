# 判断电话号码是否存在
#
# ## 
#   + **资源地址**
#   + `/tel/:tel`
#     * `tel`：电话号码
#   + **例**
#     * /tel/13810592362
# ## 数据服务
#   + 判断电话号码是否存在

app.get '/tel/:tel', (req, res) ->
  req.models.Record.findOne({'profile.tel': req.params.tel})
  .select('barcode')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    res.send (if record then true else false)
