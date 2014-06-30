models        = require '../models'
_             = require 'underscore'
fs            = require 'fs'
async         = require 'async'
fairy         = require('fairy').connect()
summarization = fairy.queue 'summarization'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'profile.tel': {'$nin': ['', null]}, appeared: {'$ne': []}})
  .select('barcode')
  .exec (error, records) ->
    return console.log error if error
    barcodes = []
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    tasks = barcodes.map (barcode) ->
      (callback) ->
        console.log barcode
        summarization.enqueue ["hswk.healskare.com", barcode], (err, res) ->
          callback(err) if err
          callback()
    async.parallel tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
