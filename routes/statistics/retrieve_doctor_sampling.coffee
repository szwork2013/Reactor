_      =  require "underscore"
moment = require "moment"

app.get '/doctor_samplings', (req, res) ->
  {Record} = req.models
  date     = moment().format('YYYY-MM-DD')
  #date     = '2013-09-27'
  Record.find({'samplings.sampled.date_string': date})
  .select('barcode samplings profile')
  .exec (error, records) ->
    return console.log error.stack if error
    results = []
    for record in records
      for sampling in record.samplings
        if sampling.status is '已采样' and sampling.sampled.date_string is date \
        and sampling.name in ['TCT标本','宫颈刮片','白带常规','心电图']
          found_sampling = _.find results, (result) ->
            result.name is sampling.name and result.doctor is sampling.sampled.user_name
          if found_sampling
            found_sampling.count += 1
          else
            results.push name: sampling.name, doctor: sampling.sampled.user_name, count: 1
    results = results.sort (a, b) -> if a.name > b.name then 1 else -1
    res.render 'doctor_samplings', {date: date, results: results}
