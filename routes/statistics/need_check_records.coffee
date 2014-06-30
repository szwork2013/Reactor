_   =  require "underscore"

app.get '/need_check_records', authorize('nurse'), (req, res) ->
  begin = (new Date).valueOf()
  {Record} = req.models
  commands = [
  ]
  commands.push
    $match  :
      'status':
        '$in': ['延期', '检查中']
  commands.push
    '$project':
      'barcode': 1
      'appeared': 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
      'profile.check_date': 1
      'profile.tel': 1
      'profile.source': 1
      'departments._id': 1
      'departments.name': 1
      'departments.status': 1
      'departments.items._id': 1
      'departments.items.name': 1
      'departments.items.status': 1
  caixue_departments = [
    '生化检验'
    '免疫检验'
    '过敏源'
    '血常规'
    '血流变'
    '全血微量元素'
    '血型'
    '血沉'
    '凝血'
  ]
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    #records = records.map (record) -> new Record record
    ignore_departments = Record.ignore_departments()
    for record in records
      record.departments = record.departments.filter (d) ->
        d.status in  ['未完成', '延期'] and d.name not in ignore_departments
      for department in record.departments
        department.name = '采血' if department.name in caixue_departments
        department.unfinished_items or = []
        every_unfinished = department.items.every (item) -> item.status is '未完成'
        if department.status is '未完成' and not every_unfinished
          department.unfinished_items = department.items
            .filter((item) -> item.status is '未完成')
            .map((item) -> item.name)
        department.schedule_items or = []
        every_scheduled = department.items.every (item) -> item.status is '延期'
        if department.status is '延期' and not every_scheduled
          department.schedule_items = department.items
            .filter((item) -> item.status is '延期')
            .map((item) -> item.name)
      unfinished_departments = record.departments.filter (d) -> d.status is '未完成'
      schedule_departments   = record.departments.filter (d) -> d.status is '延期'
      record.unfinished_departments = for name, departments of _.groupBy unfinished_departments, 'name'
        ids: departments.map((department) -> department._id).join()
        name: name
        unfinished_items: _.flatten (_.pluck(departments, 'unfinished_items')) or []
      record.unfinished_departments = _.sortBy record.unfinished_departments, (d) -> -['采血'].indexOf(d.name)
      record.schedule_departments   = for name, departments of _.groupBy schedule_departments, 'name'
        ids: departments.map((department) -> department._id).join()
        name: name
        schedule_items: _.flatten (_.pluck(departments, 'schedule_items')) or []
      record.schedule_departments = _.sortBy record.schedule_departments, (d) -> -['采血'].indexOf(d.name)
      delete record.departments
    records = records.sort (a, b) -> if a.appeared[a.appeared.length - 1] < b.appeared[b.appeared.length - 1] then 1 else -1
    res.send records
