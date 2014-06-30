_        = require "underscore"
request  = require "superagent"
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId

app.get '/batches/:batch/disease_statistics', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  {batch} = req.params
  begin = (new Date).valueOf()
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
    center_ = (new Date).valueOf()
    console.log center = (center_ - begin)
    records = records.filter (r) ->
      not r.profile.name.match(/(测试|盛保善)/) and not r.profile.division?.match(/自费/) \
      and not r.profile.division?.match(/家属/)
    results = []
    for record in records
      for suggestion in record.suggestions
        for condition in suggestion.conditions
          found_condition = _.find results, (result) -> result.name is condition.name
          guest =
            barcode:  record.barcode
            division: record.profile.division
            name:    record.profile.name
            sex:     record.profile.sex
            age:     record.profile.age or ''
          if found_condition
            found_condition.count += 1
            found_condition.guests.push guest
          else
            results.push name: condition.name, count: 1, guests: [guest]
    company = records?[0]?.profile?.source or ''
    data = [
      ["#{company}各疾病统计名单", '', '', '', '']
    ]
    for result in results
      data.push [result.name, (result.count + '人'), '', '', '']
      result.guests = result.guests.sort (a, b) ->
        if a.division > b.division then 1 else -1
      for guest in result.guests
        data.push [guest.barcode, guest.division, guest.name, guest.sex, guest.age]
      data.push ['','', '', '', '']
    center2_ = (new Date).valueOf()
    console.log center2 = (center2_ - center_)
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: company + '疾病统计', cells: data}]))
    .set('Content-Type', 'text/plain')
    .end (error, res2) =>
      console.log center3 = ((new Date).valueOf() - center2_)
      console.log error, res2
      res.redirect res2.text
