
app.get '/radiology_wait_diagnose', (req, res) ->
  {Record}    = req.models
  commands = []
  commands.push
    '$match':
      'status':
        '$in': ['检查中', '已离场']
  commands.push
    '$project':
      'departments': 1
      'barcode': 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
      'profile.check_date':1
  commands.push
    '$unwind': '$departments'
  commands.push
    '$match':
      'departments.name': '放射科'
      'departments.status': '待检验'
  commands.push
    '$unwind': '$departments.items'
  commands.push
    '$match':
      'departments.items.status': '待检验'
      'departments.items.name':
        '$in': req.user.radiology_diagnosis_parts
  commands.push
    '$project':
      'barcode': 1
      'profile.name': 1
      'profile.age': 1
      'profile.sex':1
      'profile.check_date': 1
      'profile.source': '$departments.items.name'
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    res.send records
