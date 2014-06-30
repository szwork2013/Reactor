models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'barcode': '10023112'})
  .select('barcode')
  .exec (error, records) ->
    console.log error if error
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          console.log error if error
          for department in record.departments
            if department.name.toString() is '人乳头瘤病毒'
              department.status = '未完成'
            for item in department.items
              item.status = '未完成'
          record.save callback
    console.log tasks.length
    async.parallelLimit tasks, 1000, (error) ->
      console.log if error then error else '成功'
      process.exit()
