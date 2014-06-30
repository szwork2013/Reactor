# 检索是否打印导检卡
#
# ## 检索是否打印导检卡
#   + **资源地址**
#   + `/records/:barcode/guidance_card_printed`
# ## 数据服务
#   + 成功返回{}，失败发送错误信息。

app.get '/records/:barcode/guidance_card_printed', authorize('mo', 'admin'), (req, res) ->
  req.models.Record.findOne(barcode: req.params.barcode)
  .select('guidance_card_printed')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    res.send record.guidance_card_printed
