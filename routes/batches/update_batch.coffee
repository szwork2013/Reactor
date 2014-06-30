# 修改批次信息
#
# ## 修改批次
#   + **资源地址**
#   + `/batches/:batch_id`
#   + **例**
#     * 【修改科室】
#     *  /batches/506036b8fdeedc3e31000006
#     * `req.body`内容分别如下：
#       {
#         "company": "动物所",
#         "status": "proposal"
#       }
# ## 数据服务（应用于修改批次信息）
#   + 根据编号修改批次名称、日期、状态、是否已出报告
#   + 修改科室成功后返回{}，失败发送错误信息。

app.put '/batches/:batch_id', authorize('mo', 'admin'), (req, res) ->
  {batch_id} = req.params
  {company}  = req.body
  console.log req.body, 'req.body'
  return res.send 404 if not batch_id?.match /[0-9a-f]{24}/
  {Batch, Product, Record} = req.models
  Batch.update {_id: batch_id}, { '$set': req.body }, { safe: true }
  , (error, numberAffected) ->
    return res.send error.stack, 500 if error
    return res.send 404 unless numberAffected
    res.send {}
    if company
      Product.update {batch: batch_id}, { '$set': {name: company} }, { safe: true }
      , (error, numberAffected) ->
        return console.log error.stack if error
        Record.update {'profile.batch': batch_id}, {'$set': {'profile.source': company}}, {safe: true, multi: true}
        , (error, numberAffected) ->
          return console.log error.stack if error
