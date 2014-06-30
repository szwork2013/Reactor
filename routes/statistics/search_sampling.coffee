request = require "superagent"
moment  = require "moment"

app.get '/daily_samplings', (req, res) ->
  {Record} = req.models
  date     = moment().format('YYYY-MM-DD')
  Record.find({'samplings.sampled.date_string': date})
  .select('barcode samplings profile')
  .exec (error, records) ->
    return console.log error.stack if error
    results = []
    for record in records
      for sampling in record.samplings
        if sampling.sampled.name is req.user?.user_name and sampling.sampled?.date_string is date
          results.push
            barcode: record.barcode
            name: record.profile.name
            sex:  record.profile.sex
            age:  record.profile.age
            sampling_name: sampling.name
            date_number: sampling.sampled.date_number
    results = results.sort (a, b) -> if a.date_number > b.date_number then 1 else -1
    res.send results
