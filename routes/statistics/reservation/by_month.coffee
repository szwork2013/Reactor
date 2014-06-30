# 获取指定月份的每天的预约人数情况
#
# ## 获取指定月份下每天的预约情况
#   + **资源地址**
#   + `/statistics/reservation/:year/:month`
#   + 返回结果:
#     [
#       100,
#       200,
#       300
#     ]
#   + **例**
#     *  /statistics/reservation/2012/9
# ## 数据服务（应用于个人注册中查看某月份下的每天预约人数）
#   + 根据预约日期范围条件查询档案，并统计该月份每天的预约人数
#   + 成功后返回结果数据`all_days`，失败发送错误信息。

moment = require "moment"

app.get '/statistics/reservation/:year/:month', authorize('nurse'), (req, res) ->
  {year, month} = req.params
  first_day = moment [year, month - 1, 0]
  total_days = new Date(year, month, 0).getDate()
  all_days = [0...total_days].map (i) ->
    first_day.add('days', 1).format("YYYY-MM-DD")
  commands = []
  commands.push $match:
    'profile.check_date':
      $gte: all_days[0]
      $lte: all_days[total_days - 1]
  commands.push $group:
    _id: '$profile.check_date'
    value: $sum: 1
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 400, error.stack if error
    results = results.reduce (memo, item) ->
      memo[item._id] = item.value
      memo
    , {}
    all_days = all_days.map (day) -> results[day] or 0
    res.send all_days
