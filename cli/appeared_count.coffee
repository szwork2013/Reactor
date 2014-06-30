mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  Record.find({'appeared.0': '2013-09-18'})
  .exec (error, records) ->
    return console.log error if error
    console.log records.length, 'count'
    records = records.filter (r) -> not r.profile.name.match(/测试/)
    console.log records.length
    count = 0
    for record in records
      for sampling in record.samplings
        count += 1 if sampling.tag is '生化' and sampling.status is '已采样'
    console.log count, 'count'
    process.exit()
