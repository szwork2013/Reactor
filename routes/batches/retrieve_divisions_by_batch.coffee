# 根据批次编号查找部门
#
# ## 获取的部门信息
#   + **资源地址**
#   + `/batches/:batch/divisions`
#     * `batch`：批次编号
#   + **例**
#     * 根据批次编号查找部门【选择批次带出部门信息】
#      ["部门1","部门2","部门3"]
# ## 数据服务（应用于个人注册的查询功能、拍身份证检索档案）
#   + 根据条件查询数据
#   + 查询成功返回结果数据，失败发送错误信息。

_           = require "underscore"
mongoose    = require "mongoose"
DocumentObjectId = mongoose.Types.ObjectId

app.get '/batches/:batch/divisions', authorize('cashier'), (req, res) ->
  {batch} = req.params
  batch = if batch.match /[0-9a-f]{24}/ then DocumentObjectId(batch)
  else batch
  return res.send [] if batch is 'undefined'
  commands = []
  commands.push $match:
    'profile.batch': batch
  commands.push $group:
    _id: '$profile.division'
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    divisions = (_.pluck results, '_id').filter (item) -> item
    divisions.push '其他' if '其他' not in divisions 
    res.send divisions
