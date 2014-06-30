models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'appeared': '2013-11-15'})
  .select('barcode')
  .exec (error, records) ->
    return console.log error if error
    barcodes = []
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          console.log error if error
          record.save callback
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
