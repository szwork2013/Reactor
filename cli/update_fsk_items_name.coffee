models   = require '../models'
_        = require 'underscore'
fs       = require 'fs'
barcodes = _.uniq fs.readFileSync("./barcodes.txt").toString().split('\r\n').filter((barcode) -> barcode)
async    = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  console.log barcodes.length
  #Record.find({appeared: {'$lte': '2013-11-27'}, 'mark_update2': {'$exists': false}})
  Record.find({barcode: {'$in': barcodes}})
  .select('barcode')
  .exec (error, records) ->
    console.log records.length, 'length'
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length, 'count'
    #barcodes = ['10010403', '10010402', '10010399', '10010401', '10010400']
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          callback() unless record
          fsk_department = _.find record.departments, (d) -> d.name is '放射科'
          if fsk_department
            for item in fsk_department.items
              if item._id.toString() is '300000000000000000000005'
                item.name = '胸部'
              else if item._id.toString() is '300000000000000000000007'
                item.name = '腰椎'
              else if item._id.toString() is '300000000000000000000001'
                item.name = '颈椎'
          console.log record.barcode, 'barcode'
          record.mark_update2 = on
          record.save callback
    console.log tasks.length
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
