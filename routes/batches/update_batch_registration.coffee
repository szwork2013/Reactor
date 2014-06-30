# 修改批次信息
#
# ## 修改批次
#   + **资源地址**
#   + `/batches/:batch_id/registration`
#   + **例**
#     * 【修改科室】
#     *  /batches/506036b8fdeedc3e31000006/registration
#     * `req.body`内容分别如下：
#       {
#         "_id" : "4e5bb37258200ed9aabc5da6",
#         "name": "赵英明"
#       }
# ## 数据服务（应用于修改批次的注册人）
#   + 根据编号修改批次名称、日期、状态、是否已出报告
#   + 修改科室成功后返回{}，失败发送错误信息。
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId

app.put '/batches/:batch_id/registration', authorize('mo', 'admin'), (req, res) ->
  {batch_id}   = req.params
  return res.send 404 if not batch_id?.match /[0-9a-f]{24}/
  {Batch} = req.models
  Batch.update {_id: batch_id}, { '$set': {'registration._id': ObjectId(req.body._id), 'registration.name': req.body.name} }, { safe: true }
  , (error, numberAffected) ->
    return res.send error.stack, 500 if error
    return res.send 404 unless numberAffected
    res.send {}
