# field_complete_situations?from={from}&to={to}
# 打印人数
# 完成人数
# 离场人数

app.get '/field_complete_situations', (req, res) ->
  {Record}   = req.models
  {from, to} = req.query
  commands = []
  commands.push
    '$match':
      'field_complete.date_string':
        '$gte': from
        '$lte': to
      'status':'$in': ['已离场', '已完成', '已打印', '已发电子报告']
  commands.push
    '$project':
      'field_complete': '$field_complete.date_string'
      'barcode': 1
      'status': 1
      'paper_report': 1
      'notes': '$profile.notes'
  commands.push
    '$sort':
      'field_complete': -1
  commands.push
    '$group':
      '_id': '$field_complete'
      'records':
        '$push':
          'barcode': '$barcode'
          'status':  '$status'
          'paper_report': '$paper_report'
          'notes': '$notes'
  Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    for result in results
      result.finished = result.records
        .filter((record) -> record.status is '已完成' and record.paper_report and not record.notes.some((note) -> note.match(/电子报告/))).length
      # TODO: HACK
      result.electron_report = result.records.filter((record) -> record.status in ['仅由电子报告', '已发电子报告', '已完成'] and (not record.paper_report or record.notes.some((note) -> note.match(/电子报告/)))).length
      result.printed  = result.records.filter((record) -> record.status is '已打印').length
      result.leaved   = result.records.filter((record) -> record.status is '已离场').length
      delete result.records
    res.send results
