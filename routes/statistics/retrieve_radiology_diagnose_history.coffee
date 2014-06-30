moment = require 'moment'

app.get '/radiology_diagnose_history', (req, res) ->
  {Record}    = req.models
  begin_date1 = moment().subtract('days', 20).format('YYYY-MM-DD')
  begin_date2 = moment().subtract('days', 7).format('YYYY-MM-DD')
  end_date    = moment().format('YYYY-MM-DD')
  commands = []
  commands.push
    '$match':
      'profile.check_date':
        '$gte': begin_date1
        '$lte': end_date
  commands.push
    '$project':
      'departments': 1
      'barcode': 1
      'profile.name':1
      'profile.sex': 1
      'profile.age': 1
  commands.push
    '$unwind': '$departments'
  commands.push
    '$match':
      'departments.name': '放射科'
  commands.push
    '$unwind': '$departments.items'
  commands.push
    '$match':
      'departments.items.checking.finished.user_name': req.user.name
      'departments.items.status': '已完成'
      'departments.items.checking.finished.date_string':
        '$gte': begin_date2
        '$lte': end_date
  commands.push
    '$project':
      'barcode': 1
      'profile.name': 1
      'profile.age': 1
      'profile.sex':1
      'profile.source': '$departments.items.name'
      'profile.check_date': '$departments.items.checking.finished.date_string'
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    res.send records
