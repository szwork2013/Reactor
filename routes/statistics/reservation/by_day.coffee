# 获取指定日的时间段的预约人数情况
#
# ## 获取指定日下的时间段的预约情况
#   + **资源地址**
#   + `/statistics/reservations/:year/:month/:day`
#   + **例**
#     * `/statistics/reservations/2012/9/1
#     * 返回结果：
#       {
#         "A": 50
#         "B": 23
#       }
# ## 数据服务（应用于个人注册中查看某天的时间段下的预约人数）
#   + 根据预约日期条件查询档案，并统计该天的所使用时间段下的预约人数
#   + 成功后返回结果数据，失败发送错误信息。

moment = require "moment"

app.get '/statistics/reservation/:year/:month/:day', authorize('doctor') 
,(req, res) ->
  {year, month, day} = req.params
  date  = (moment [year, month - 1, day]).format("YYYY-MM-DD")
  commands = []
  commands.push $match:
    'profile.check_date': date
  commands.push $group:
    _id: '$profile.check_time'
    value: $sum: 1
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 400, error.stack if error
    res.send results.sort((result) -> result._id).reverse().reduce (memo, result) ->
      memo[result._id] = result.value
      memo
    , {}
