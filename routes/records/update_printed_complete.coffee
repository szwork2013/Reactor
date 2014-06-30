# 标记打印完成
#
# ## 
#   + **资源地址**
#   + `/records/:barcode/report_printed`
#   + **例**
#     *  /records/10000001/report_printed
# ## 数据服务（应用于标记打印完成）
#   + 根据档案编号查询档案
#   + 添加修改项成功后返回{}，失败发送错误信息。

app.post '/records/:barcode/report_printed', (req, res) ->
  updator =
    status: '已打印'
    printed_complete: req.event
  console.log req.user
  console.log req.event
  {barcode} = req.params
  {Record}  = req.models
  Record.findOne(barcode: barcode)
  .select('status')
  .exec (error, record) ->
    console.log 'query record error', error.stack if error
    return res.send 500, error.stack if error
    return res.send 403 if record.status not in ['已完成', '已打印', '已发电子报告']
    console.log updator
    Record.update {barcode: barcode}, {'$set': updator, '$inc': {print_counter: 1}}
    , { safe: true }, (error, numberAffected) ->
      console.log 'update print counter error', error.stack if error
      return res.send 500, error.stack if error
      return res.send 403 unless numberAffected
      res.send {}
