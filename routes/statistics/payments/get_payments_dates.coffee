moment = require 'moment'

app.get '/statistics/payments/dates', (req, res) ->
  {begin, end} = req.query
  first_day  = begin or moment().format("YYYY-MM-DD")
  last_day   = end or moment().format("YYYY-MM-DD")
  commands = []
  commands.push
    $match:
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
    'payments.staff.date_string': 1
  commands.push $group:
    _id: '1'
    dates:
      $addToSet: '$payments.staff.date_string'
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    result = results[0] or {}
    res.send result.dates or []
