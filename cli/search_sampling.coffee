models = require '../models'
_      = require 'underscore'

models 'test.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'samplings.sample.date_string': '2013-09-27'})
  .select('barcode samplings profile')
  .exec (error, records) ->
    return console.log error.stack if error
    console.log records.length, 'count'
    results = []
    for record in records
      samplings = {}
      for sampling in record.samplings
        if sampling.sample.name
          samplings[sampling.sample.name] or = []
          samplings[sampling.sample.name].push sampling.name
      for key, value of samplings
        results.push
          barcode: record.barcode
          name: record.profile.name
          sex:  record.profile.sex
          age:  record.profile.age
          sampling_doctor: key
          sampling_name: value.join(' ')
    for result in results
      console.log result.name, result.sex, result.age, result.sampling_doctor, result.sampling_name
    process.exit()
