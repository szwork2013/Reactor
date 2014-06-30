# 获取指定日期的结算明细
#
# ## 
#   + **资源地址**
#   + `/statistics/payments/:year/:month/:day/details`
#   + **例**
#     * `/statistics/payments/:year/:month/:day/details`
#      [
#        {
#          "category" : "现金",
#          "name" : '张三',
#          "sex": '男',
#          "age": '25',
#          'authenticated': true,
#          'package_count': 2,
#          'combo_count': 1
#        }
#      ]
#
# ## 数据服务（应用于查询某天的结算明细）
#   + 按天统计结算明细信息（银行卡或现金消费明细信息）
#   + 成功后返回结果数据，失败发送错误信息。
moment = require 'moment'

app.get '/statistics/payments/:year/:month/:day/details', authorize('cashier')
,(req, res) ->
  {year, month, day} = req.params
  date  = (moment [year, month - 1, day]).format("YYYY-MM-DD")
  commands = []
  commands.push
    $match:
      #'profile.name':
      # '$nin':[new RegExp('ceshika|test|测试')]
      'payments.staff.date_string': date
  commands.push
    $project:
      payments: 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
  commands.push
    $unwind: '$payments'
  commands.push
    $match:
      'payments.staff.date_string': date
  req.models.Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    results = []
    results = for record in records
      method: if record.payments.cash then '现金' else '银行卡'
      category: record.payments?.category
      amount: record.payments.amount
      name: record.profile.name
      sex: record.profile.sex
      age: record.profile.age
      authorizer: record.payments?.authorization?.name or ''
      package_count: record.payments.items.filter((item) -> item.category is 'package').length
      combo_count: record.payments.items.filter((item) -> item.category is 'combo').length
    res.send results
