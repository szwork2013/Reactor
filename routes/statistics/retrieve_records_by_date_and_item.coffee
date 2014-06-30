_      =  require "underscore"

app.get '/records/:date/:item/profiles', (req, res) ->
  {Record}       = req.models
  {date, item}   = req.params
  commands = []
  commands.push
    '$match':
      'appeared': date
  commands.push
    '$project':
      'barcode': 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
      'samplings': 1
      'departments': 1
  commands.push
    '$unwind': '$samplings'
  commands.push
    '$unwind': '$departments'
  commands.push
    '$unwind': '$departments.items'
  commands.push
    '$match':
      'samplings.tag': '生化'
      'samplings.sampled.date_string': date
      'departments.name': '生化检验'
      'departments.items.name': item
      'departments.items.status': '已完成'
  commands.push
    '$project':
      '_id': 0
      'barcode': 1
      'name': '$profile.name'
      'sex':  '$profile.sex'
      'age':  '$profile.age'
      'item': '$departments.items'
  Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    res.send results
