mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  Record.find({'profile.source': '和利时'})
  .exec (error, records) ->
    return console.log error if error
    console.log records.length, 'count'
    ysz_count = 0
    ncg_count = 0
    for record in records
      for department in record.departments
        if department.name is '咽拭子' and department.status is '已完成'
          ysz_count += 1
        if department.name is '尿常规' and department.status is '已完成'
          ncg_count += 1
    console.log ysz_count, ncg_count
    process.exit()
