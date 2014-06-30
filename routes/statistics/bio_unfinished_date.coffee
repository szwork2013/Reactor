# 获取统计未完成生化的采样日期集合
#
# ## 获取统计未完成生化的采样日期集合
#   + **资源地址**
#   + `/statistics/bio_unfinished_date`
#   + **例**
#     * `/statistics/bio_unfinished_date
#     * 返回结果：
#       {
#         "2013-01-02",
#         "2014-03-05"
#       }
# ## 数据服务（应用于统计未完成生化的采样日期集合）
#   + 统计未完成生化的采样日期集合
#   + 成功后返回结果数据，失败发送错误信息。
_      = require "underscore"
moment = require "moment"

app.get '/statistics/bio_unfinished_date', authorize('doctor')
,(req, res) ->
  commands = []
  commands.push
    '$match':
      'biochemistry.audit.date_string':
        '$exists': false
  commands.push
    '$project':
      barcode: 1
      biochemistry: 1
      samplings: 1
  commands.push
    '$unwind': '$samplings'
  commands.push
    '$match':
      'samplings.tag':'生化'
  commands.push
    '$group':
      '_id': '$samplings.sampled.date_string'
      'barcode':
        '$first': '$barcode'
  commands.push
    '$sort':
      '_id': 1
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 400, error.stack if error
    console.log results, 'results'
    dates = (_.pluck results, '_id').filter (date) -> date
    res.send dates
