fs = require 'fs'
_  = require 'underscore'
async = require "async"
recordSchema = require('../models') 'hswk.healskare.com', (err, models) ->

  Record   = models.Record

  barcodes = _.uniq fs.readFileSync(process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

  records = []

  tasks = barcodes.map (barcode) -> (callback) ->
    Record.barcode barcode, {}, (error, record) ->
      return console.log barcode, error.stack if error
      uncomplete_departments = record.departments.filter (d) -> d.status in ['未完成', '未采样', '待检验']
      if uncomplete_departments.length
        records.push barcode: barcode, departments: _.pluck(uncomplete_departments, 'name')
      callback()

  async.parallel tasks, () ->
    records = records.sort (a, b) -> if a.barcode > b.barcode then 1 else -1
    for record in records
      console.log record.barcode + '：' + record.departments
    process.exit()
