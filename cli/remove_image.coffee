models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  fs.readdir "../public/images", (error, files) ->
    files = files.map (file) -> file.split('.')[0]
    console.log files
    Record.find({appeared: '2013-09-17'})
    .select('barcode')
    .exec (error, records) ->
      console.log error if error
      barcodes = _.pluck records, 'barcode'
      tasks = barcodes.map (barcode) ->
        console.log barcode
        (callback) ->
          Record.barcode barcode, {paid_all:on}, (error, record) ->
            console.log error if error
            record.images = record.images.filter (image) -> image._id.toString() in files
            record.save callback
      console.log tasks.length
      async.series tasks, (error) ->
        console.log if error then error else '成功'
        process.exit()
