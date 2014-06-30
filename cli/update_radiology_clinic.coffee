models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find()
  .select('barcode')
  .sort('barcode')
  .skip(10000)
  .limit(1000)
  .exec (error, records) ->
    return console.log error if error
    console.log records.length, 'count'
    barcodes = []
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.findOne(barcode: barcode)
        .exec (error, record) ->
          console.log error if error
          console.log 11111111
          for department in record.departments
            if department.name is '放射科'
              console.log department.category, 'before', barcode
              department.category = 'clinic'
              console.log department.category, 'after', barcode
          record.save callback
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
