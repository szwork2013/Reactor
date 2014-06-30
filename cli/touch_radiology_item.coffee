models   = require '../models'
_        = require 'underscore'
fs       = require 'fs'
barcodes = ['10000664'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async    = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({mark_update: {'$exists': false}})
  .select('barcode')
  .exec (error, records) ->
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          callback() unless record
          for department in record.departments
            if department.name is '放射科'
              for item in department.items
                item.name = item.name.replace(/、/, '')
          console.log record.barcode, 'barcode'
          record.mark_update = on
          record.save callback
    console.log tasks.length
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
