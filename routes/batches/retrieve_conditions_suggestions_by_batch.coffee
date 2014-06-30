_        = require "underscore"
request  = require "superagent"
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId

app.get '/batches/:batch/conditions_suggestions', authorize('doctor', 'admin'), (req, res) ->
  {Record, SuggestionGroup} = req.models
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
      not r.profile.name.match(/(测试|盛保善)/) and not r.profile.division?.match(/自费/)
    results = []
    {cached_suggestions_hash} = SuggestionGroup
    for record in records
      for suggestion in record.suggestions
        for condition in suggestion.conditions
          found_condition = _.find results, (result) -> result.name is condition.name
          if found_condition
            found_condition.count += 1
          else
            results.push name: condition.name, suggestion: (cached_suggestions_hash?[condition.name]?[0]?.content or ''), count: 1
    data = [
      ["#{records[0]?.profile.source}阳性体征建议", ""]
      ["汇总人数：#{records.length}，统计列表如下：", ""]
      ['疾病名称', '建议']
    ]
    results = results.sort (a, b) -> if a.count > b.count then -1 else 1
    for result in results
      data.push [result.name, result.suggestion]
   
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: records[0]?.profile.source + '症状建议统计', cells: data}]))
    .set('Content-Type', 'text/plain')
    .end (error, res2) =>
      console.log error, res2
      res.redirect res2.text
