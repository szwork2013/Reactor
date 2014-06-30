models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

#summarization.enqueue ["hswk.healskare.com", barcode], (err, res) ->

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Batch = models.Batch
  #Record.find({'profile.batch': '521aea17c14a03637e000005'})
  #Batch.find({status: 'ongoing'})
  #.select('status')
  #.exec (error, batches) ->
  # return console.log error if error
  # ids = _.pluck(batches, '_id')
  # Record.find({'profile.batch': '51c05a481e8570b51200000b'})
  Record.find({'barcode': '10026320'})
  .select('barcode')
  .exec (error, records) ->
    return console.log error if error
    barcodes = []
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          return callback error if error
          console.log barcode, 'barcode'
          orderids = _.pluck record.orders, '_id'
          Record.set_paper_report barcode, orderids, (error) ->
            return callback(error) if error
            callback()
          # bp = _.find record.departments, ((department) -> department.name is '血压')
          # console.log bp
          # bp = _.find (bp?.items or []), (item) -> item.name is '血压'
          # bp = bp?.value
          # hr = _.find record.departments, ((department) -> department.name is '内科')
          # hr = _.find (hr?.items or []), (item) -> item.name is '心率'
          # hr = hr?.value
          # console.log record.barcode, bp, hr if hr is '76' and bp is '140/80'
          #record.no_empty = undefined
          #delete record.no_empty
          #console.log 11111111, record.barcode
          #record.save callback
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
