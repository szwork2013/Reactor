models   = require '../models'
_        = require 'underscore'
fs       = require 'fs'
barcodes = ['10000664'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async    = require 'async'
moment   = require 'moment'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'field_complete.date_string': {'$gte': '2013-11-25', '$lte': '2013-11-29'}})
  .select('barcode')
  .exec (error, records) ->
    barcodes = _.pluck records, 'barcode'
    #barcodes = ['10010403', '10010402', '10010399', '10010401', '10010400']
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          callback() unless record
          gmd_department = _.find record.departments, (d) -> d.name is '骨密度'
          if gmd_department?.status is '已完成' and not record.appeared.length
            record.appeared.push moment().format('YYYY-MM-DD')
          console.log record.barcode, 'barcode'
          record.save callback
    console.log tasks.length
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
