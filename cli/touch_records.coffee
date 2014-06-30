models = require '../models'
_ = require 'underscore'
fs = require 'fs'
barcodes = ['10000664'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'
models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  #Record.find({'field_complete.date_string': {'$gte': '2013-12-25'}})
  Record.find({'profile.check_date': {'$gte': '2014-02-01'}})
  .select('barcode')
  .exec (error, records) ->
    barcodes = _.pluck records, 'barcode'
    console.log records.length
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          callback() unless record
          record.save (error) ->
            return callback error if error
            callback()

    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
