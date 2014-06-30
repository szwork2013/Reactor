_      =  require "underscore"

app.get '/records/biochemistry_items/:date', (req, res) ->
  {Record} = req.models
  {date}   = req.params
  commands = []
  commands.push
    '$match':
      'appeared': date
  commands.push
    '$project':
      'departments': 1
      'samplings': 1
  commands.push
    '$unwind': '$departments'
  commands.push
    '$unwind': '$samplings'
  commands.push
    '$match':
      'samplings.tag': '生化'
      'samplings.sampled.date_string': date
      'departments.name': '生化检验'
  commands.push
    '$unwind': '$departments.items'
  commands.push
    '$match':
      'departments.items.status': '已完成'
  commands.push
    '$project':
      '_id': 0
      'name': '$departments.items.name'
  Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    results = _.pluck results, 'name'
    results = _.uniq results
    res.send results
