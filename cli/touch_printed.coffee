models = require '../models'
_ = require 'underscore'
fs = require 'fs'
barcodes = ['10000664'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'
models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'field_complete.date_string': process.argv[2]})
  #Record.find({'appeared': '2013-08-27', 'departments.status': {'$in': ['延期', '未完成']}})
  #Record.find({barcode: {'$in': ['10025986', '10026033', '10026026']}})
  .select('barcode')
  .exec (error, records) ->
    console.log records.length, 'count'
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          return callback() unless record
          #return callback() if record.profile.id is '612730198904160022'
          record.status = '已完成'
          record.print_counter = undefined
          record.printed_complete = undefined
          record.save callback
    console.log tasks.length
    async.parallelLimit tasks, 20, (error) ->
      console.log if error then error else '成功'
      process.exit()
