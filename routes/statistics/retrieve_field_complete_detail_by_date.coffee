# days/:date/field_complete_detail
# 检索某特定时间的现场完成详细
_ = require 'underscore'

app.get '/days/:date/field_complete_detail', (req, res) ->
  {Record} = req.models
  {date}   = req.params
  commands = []
  commands.push
    '$match':
      'field_complete.date_string': date
      'status':'$in': ['已离场', '已完成', '已打印', '已发电子报告']
  commands.push
    '$project':
      'barcode': 1
      'profile.name': 1
      'profile.age': 1
      'profile.sex': 1
      'profile.check_date': 1
      'profile.source': 1
      'profile.division': 1
      'status': 1
      'paper_report': 1
      'notes': '$profile.notes'
      'field_complete': '$field_complete.date_string'
  commands.push
    '$sort':
      'field_complete': 1
  commands.push
    '$group':
      '_id': '$status'
      'records':
        '$push':
          'barcode': '$barcode'
          'name': '$profile.name'
          'sex': '$profile.sex'
          'age': '$profile.age'
          'source': '$profile.source'
          'division': '$profile.division'
          'status': '$status'
          'paper_report': '$paper_report'
          'notes': '$notes'
          'field_complete': '$field_complete'
  Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    found_complete = _.find results, (item) -> item._id is '已完成'
    # if found_complete
    #   found_complete.records = found_complete.records.filter (record) ->
    #     record.status is '已完成' and record.paper_report and not record.notes.some((note) -> note.match(/电子报告/))
    # HACK
    # TODO: 更正HACK
    if found_complete
      elec = found_complete.records.filter (record) ->
        not record.paper_report or record.notes.some((note) -> note.match(/电子报告/))
      found_complete.records = _(found_complete.records).difference elec
    dianziabogao = _.find results, (item) -> item._id is '已发电子报告'
    if dianziabogao
      dianziabogao.records = dianziabogao.records.concat elec
    else
      results.push
        _id: '已发电子报告'
        records: elec
    res.send results
