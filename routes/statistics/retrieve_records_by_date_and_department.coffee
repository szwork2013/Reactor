# /days/:date/laboratory_departments/:department
# 检索特定检完日期和特定科室下的客人体检项目情况


app.get '/days/:date/laboratory_departments/:department', (req, res) ->
  {Record, Department} = req.models
  {date, department}   = req.params
  commands = []
  commands.push
    '$match':
      'field_complete.date_string': date
      'status':'$in': ['已离场', '已发电子报告', '已完成', '已打印']
  commands.push
    '$project':
      'barcode': 1
      'profile.name': 1
      'profile.age': 1
      'profile.sex': 1
      'departments._id': 1
      'departments.category': 1
      'departments.name': 1
      'departments.status': 1
      'departments.items.name': 1
      'departments.items.status': 1
  commands.push
    '$unwind': '$departments'
  commands.push
    '$match':
      'departments.name': department
      'departments.status':
        '$in': ['待检验', '已上机未完成', '待审核', '已完成']
  commands.push
    '$group':
      '_id':            '$departments.status'
      'records':
        '$push':
          'barcode':    '$barcode'
          'name':       '$profile.name'
          'age':        '$profile.age'
          'sex':        '$profile.sex'
          '_id':        '$departments._id'
          'category':   '$departments.category'
          'department': '$departments.name'
          'status':     '$departments.status'
          'items':      '$departments.items'
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    res.send records
