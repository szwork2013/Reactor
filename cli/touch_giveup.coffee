models = require '../models'
_ = require 'underscore'
fs = require 'fs'
barcodes = ['10000664'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'
models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'appeared': {'$lte': '2013-10-27'}, 'departments.status': {'$in': ['延期', '未完成']}})
  #Record.find({'appeared': '2013-08-27', 'departments.status': {'$in': ['延期', '未完成']}})
  #Record.find({barcode: '10007007'})
  .select('barcode')
  .exec (error, records) ->
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          callback() unless record
          departments = record.departments.filter (d) -> d.status in ['延期', '未完成']
          for department in departments
            console.log 11111111111111111
            for item in department.items
              console.log 22222222222222
              item.status = '放弃'
            department.status = '放弃'
          console.log departments, 'departments'
          record.save callback
    console.log tasks.length
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
