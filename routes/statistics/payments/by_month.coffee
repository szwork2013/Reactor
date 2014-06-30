# 获取某月的结算信息
#
# ## 按天查询结算信息
#   + **资源地址**
#   + `/statistics/payments/:year/:month`
#   + **例**
#     * `/statistics/payments/2012/11`
#     * 返回结果：
#       {
#         "cash" : 200,          //现金
#         "transfer" : 100,      //银行卡消费金额
#       }
# ## 数据服务（应用于结算信息查询）
#   + 按天统计结算信息（现金cash、银行卡消费金额transfer、
#     会员卡消费金额membership、套餐卡张数package）
#   + 成功后返回结果数据，失败发送错误信息。
moment = require 'moment'

app.get '/statistics/payments/:year/:month', (req, res) ->
  {year, month} = req.params
  first_day  = (moment [year, month - 1, 0]).format("YYYY-MM-DD")
  last_day   = (moment [year, month, 0]).format("YYYY-MM-DD")
  commands = []
  commands.push
    $match:
      #'profile.name':
      # '$nin':[new RegExp('ceshika|test|测试')]
      'payments.staff.date_string':
        '$gte': first_day
        '$lte': last_day
  commands.push $project: payments: 1
  commands.push $unwind:'$payments'
  commands.push
    $match:
      'payments.staff.date_string':
        '$gte': first_day
        '$lte': last_day
  commands.push $project:
    'payments.cash': 1
    'payments.transfer': 1
    'payments.staff.date_string': 1
  commands.push $group:
    _id: '1'
    cash:
      $sum: "$payments.cash"
    transfer:
      $sum: '$payments.transfer'
    dates:
      $addToSet: '$payments.staff.date_string'
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    result = results[0] or {}
    result.total = (result.cash or 0) + (result.transfer or 0)
    res.send result
