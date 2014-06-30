_            = require 'underscore'
mongoose     = require 'mongoose'
request      = require 'superagent'
moment       = require "moment"
ObjectId     = mongoose.Types.ObjectId

app.get '/batches/:batch/records_conditions', authorize('doctor', 'admin'), (req, res) ->
  begin = (new Date).valueOf()
  {Record}  = req.models
  {batch} = req.params
  commands = []
  commands.push
    '$match':
      'profile.batch': new ObjectId batch
      'non_empty': on
  commands.push
    '$project':
      'barcode': 1
      'appeared': 1
      'profile.source': 1
      'profile.division': 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
      'departments.items.name': 1
      'departments.items.conditions': 1
  commands.push
    '$sort':
      'barcode': 1
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    console.log center = ((new Date).valueOf() - begin)
    records = records.filter (r) ->
      not r.profile.name.match(/(测试|盛保善)/) and not r.profile.division?.match(/自费/) \
      and not r.profile.division?.match(/家属/)
    #records = records.map (record) -> record.toObject()
    titles = ['编号', '姓名', '性别', '年龄', '部门', '阳性症状']
    records = records.sort (a, b) -> if a.profile.division > b.profile.division then 1 else -1
    console.log records.length, 'length'
    male = 0
    female = 0
    total = 0
    guests = []
    for record in records
      record.conditions = []
      for department in record.departments
        for item in department.items
          for condition in item.conditions
            if condition.name in ['阴性', '弱阳性', '阳性', '偏高', '偏低']
              condition.name = item.name + condition.name
            name = condition.summary or condition.name
            record.conditions.push name if name not in record.conditions
      if record.conditions.length
        male += 1 if record.profile.sex is '男'
        female += 1 if record.profile.sex is '女'
        total += 1
        guests.push [
          record.barcode
          record.profile.name
          record.profile.sex
          (record.profile.age or '')
          (record.profile.division or '')
          record.conditions.join('、')
        ]
    datas = []
    datas.push [
      '体检阳性结果人员共计' + total + '人，其中男' + male + '人，女' + female + '人\n'
      ''
      ''
      ''
      ''
      ''
    ]
    datas.push titles
    for guest in guests
      datas.push guest
    #console.log datas, 'datas'
    console.log center2  = ((new Date).valueOf() - center)
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: (records?[0]?.profile?.source or '') + '疾病清单', cells: datas}]))
    .set('Content-Type', 'text/plain')
    .end (error, res2) =>
      console.log center3 = (new Date).valueOf() - center2

      console.log error, res2
      res.redirect res2.text
