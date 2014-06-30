models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({appeared: {'$gte': '2013-07-01', '$lte': '2013-12-31'}})
  .select('barcode profile')
  .exec (error, records) ->
    console.log error if error
    console.log records.length, 'count'
    company_appeared_count = {}
    records = records.filter((record) -> not record.profile.name.match(/测试/))
    for record in records
      company_appeared_count[record.profile.source] or = 0
      company_appeared_count[record.profile.source] += 1
    results = []
    for name, count of company_appeared_count
      results.push name: name, count: count
    results = results.sort((a, b) -> if a.count > b.count then -1 else 1)
    for {name, count} in results
      console.log name, count
