
app.get '/radiology_records', authorize('cashier'), (req, res) ->
  {keywords} = req.query
  {Record}   = req.models
  return res.send [] if keywords is ''
  if keywords
    criteria = [
      ('profile.name': new RegExp "^#{keywords.replace(/[\*\＊]/g, '(.*)').replace(/[?？]/g, '(.{1})')}$")
      ('profile.name_pinyin': new RegExp "^#{keywords.toUpperCase().replace(/[\*\＊]/g, '(.*)').replace(/[?？]/g, '(.{1})')}$")
      ('profile.id': keywords)
      ('profile.tel': keywords)
      ('barcode': keywords)
    ]
  tags = req.user?.radiology_diagnosis_parts?.map((part) -> '放射科:' + part) or []
  query =
    '$or': criteria
    'images.tag':
      '$in': tags
  delete query['$or'] unless criteria
  
  commands = []
  commands.push
    '$match': query
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
      'departments.items.name':
        '$in': req.user?.radiology_diagnosis_parts
  commands.push
    '$project':
      'barcode': 1
      'profile.name': 1
      'profile.age': 1
      'profile.sex':1
      'profile.source': '$departments.items.name'
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    res.send records
