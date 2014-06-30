# 修改同意签署协议书
#
# ## 修改同意签署协议书
#   + **资源地址**
#   + `/records/:barcode/hbv_agreement_signed`
# ## 数据服务（应用于前台）
#   + 修改同意签署协议书
#   + 修改成功返回{}，失败发送错误信息。

# TODO: `hbv_agreement_signed`是动词，只能用`POST`方法。
# TODO: 对`s(uper)u(ser)`全部放行，在`authorize`中实现，不在每次API中重新叙述。
app.post '/records/:barcode/hbv_agreement_signed', authorize('mo', 'admin'), (req, res) ->
  {Record} = req.models
  Record.findOne(barcode: req.params.barcode)
  .select('profile.name hbv_agreement_signed')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    hbv_agreement_signed = not record.hbv_agreement_signed
    Record.update {barcode: req.params.barcode}, {'$set': {hbv_agreement_signed: hbv_agreement_signed}}, {safe: on}, (error, number_affected) ->
      return res.send 500, error.stack if error
      res.send {name: record.profile.name, hbv_agreement_signed: hbv_agreement_signed}
