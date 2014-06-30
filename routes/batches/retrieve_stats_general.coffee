# 查询某批次下的客人所使用的指定小套餐的预约时间和人数情况
#
# ## 
#   + **资源地址**
#   + `/batches/:batch_id/configurations/:configuration_id/stats/general`
#   + **例**
#     {
#       check_data: ["2012-10-06"]
#       registered: 20
#       appeared:10
#       finished:5
#       printed: 3
#      }
# ## 数据服务（应用于查询预约时间和人数情况）
#   + 根据条件查询数据
#   + 查询成功返回结果，失败发送错误信息。
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId

app.get '/batches/:batch_id/stats/general', authorize('admin'), (req, res) ->
  {batch_id} = req.params
  return res.send 404 if not batch_id?.match /[0-9a-f]{24}/
  {Record} = req.models
  commands = []
  commands.push
    '$match':
      'profile.batch': ObjectId batch_id 
  commands.push
    '$project':
      '_id': 1
      'check_date': '$profile.check_date'
      'appeared': $cond: [ {$eq:['$appeared', []]}, 0, 1]
      'finished': $cond: ['$report_complete',1,0]
      'printed':  $cond: ['$printed_complete',1,0]
  commands.push
    '$group':
      '_id': '$check_date'
      'registered':
        '$sum': 1
      'appeared':
        '$sum': '$appeared'
      'finished':
        '$sum': '$finished'
      'printed':
        '$sum': '$printed'
  Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    result = results.reduce (memo, item) ->
      memo.check_date.push item._id
      memo.registered += item.registered
      memo.appeared += item.appeared
      memo.finished += item.finished
      memo.printed += item.printed
      memo
    , {check_date: [], registered: 0, appeared: 0, finished: 0, printed: 0}
    res.send result
