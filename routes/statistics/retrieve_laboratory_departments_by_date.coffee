# /days/:date/laboratory_departments
# 检索特定检完日期下的实验室科室检查情况

_  = require "underscore"

app.get '/days/:date/laboratory_departments', (req, res) ->
  {Record, Department} = req.models
  {date}   = req.params
  commands = []
  commands.push
    '$match':
      'field_complete.date_string': date
      'status':'$in': ['已离场', '已发电子报告', '已完成', '已打印']
  commands.push
    '$project':
      'barcode': 1
      'status': 1
      'departments._id': 1
      'departments.category': 1
      'departments.name': 1
      'departments.status': 1
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    departments_orders = Department.cached_departments_orders
    results = []
    for record in records
      record.departments = record.departments.filter (d) ->
        d.category is 'laboratory' or d.name in ['放射科', '心电图']
      for department in record.departments
        found_department = _.find results, (result) -> result.name is department.name
        result =
          name: department.name
          order: departments_orders[department._id]
          unfinished: 0
          finished: 0
        if department.status in ['待检验', '已上机未完成', '待审核']
          if found_department
            found_department.unfinished += 1
          else
            result.unfinished = 1
            results.push result
        else if department.status is '已完成'
          if found_department
            found_department.finished += 1
          else
            result.finished = 1
            results.push result
    results = results.sort (a, b) -> if a.order > b.order then 1 else -1
    res.send
      unfinished_departments: results.filter((result) -> result.unfinished)
      finished_departments:   results.filter((result) -> not result.unfinished)
