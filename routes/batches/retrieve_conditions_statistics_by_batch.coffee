_        = require "underscore"
request  = require "superagent"
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId

app.get '/batches/:batch/conditions_statistics', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  {batch} = req.params
  commands = []
  commands.push
    '$match':
      'profile.batch': new ObjectId batch
      'non_empty': on
  commands.push
    '$project':
      'barcode': 1
      'profile.source': 1
      'profile.division': 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
      'suggestions': 1
  commands.push
    '$sort':
      'barcode': 1
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    records = records.filter (r) ->
      not r.profile.name.match(/(测试|盛保善)/) and not r.profile.division?.match(/自费/) \
      and not r.profile.division?.match(/家属/)
    results = []
    for record in records
      for suggestion in record.suggestions
        for condition in suggestion.conditions
          found_condition = _.find results, (result) -> result.name is condition.name
          if found_condition
            found_condition.count += 1
            if record.profile.sex is '男'
              found_condition.male += 1
            else
              found_condition.female += 1
          else
            results.push name: condition.name, count: 1, male: (if record.profile.sex is '男' then 1 else 0), female: (if record.profile.sex is '女' then 1 else 0)
    data = [
      ["#{records[0]?.profile.source}阳性体征人数统计表", '' , '', '', '', '', '']
      ["汇总人数：#{records.length}，统计列表如下：", "", "", '', '', '', '']
      ['疾病名称', '男', '占总检人数百分比', '女', '占总检人数百分比', '合计','占总检人数百分比']
    ]
    results = results.sort (a, b) -> if a.count > b.count then -1 else 1
    male_total   = records.filter((r) -> r.profile.sex is '男').length
    female_total = records.filter((r) -> r.profile.sex is '女').length
    for result in results
      bfb = ((result.count/records.length) * 100).toFixed(2)
      if bfb > 5
        data.push [result.name, result.male, ((result.male/male_total) * 100).toFixed(2), result.female, ((result.female/female_total) * 100).toFixed(2), result.count, ((result.count/records.length) * 100).toFixed(2)]
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: records[0]?.profile.source + '症状统计', cells: data}]))
    .set('Content-Type', 'text/plain')
    .end (error, res2) =>
      #console.log error, res2
      res.redirect res2.text
