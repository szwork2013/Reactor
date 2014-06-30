models       = require "../models"
subdomain    = 'hswk.healskare.com'
fs           = require 'fs'
_            = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  console.log 1111111111
  Record = models.Record
  Record.find()#({appeared:{$gte: '2013-07-01' , $lte: '2013-12-31'}})
  .exec (error, records) ->
    return console.log error if error
    console.log records, 'records'
    #console.log records.length, 'count'
    #records = records.filter((record) -> not record.profile.name.match(/测试/))
    #for record in records
    # company_appeared_count[record.profile.source] or = 0
    # company_appeared_count[record.profile.source] += 1
    #results = []
    #for name, count of company_appeared_count
    # results.push name: name, count: count
    #results = results.sort((a, b) -> if a.count > b.count then -1 else 1)
    #for {name, count} in results
    # console.log name, count
