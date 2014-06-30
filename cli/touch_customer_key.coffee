models   = require '../models'
_        = require 'underscore'
fs       = require 'fs'
barcodes = ['10000664'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async    = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({appeared: {'$lte': '2013-11-27'}, 'departments.items.name': {'$in': ['胸部侧位片','腰椎侧位片', '颈椎正位片']}})
  .select('barcode')
  .exec (error, records) ->
    barcodes = _.pluck records, 'barcode'
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
          record.save callback
    console.log tasks.length
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
