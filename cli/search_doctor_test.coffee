models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'profile.notes':{'$ne': '外检'}, 'profile.source': {'$nin': ['开关厂（外检）', '中科院科技服务公司（外检）', '和利时（外检）', '中科院机关（外检）', '电子六所（外检）']}})
  #Record.find({barcode: {'$in': barcodes}})
  .select('barcode profile.notes')
  .exec (error, records) ->
    console.log error if error
    records = records.filter (r) -> '外检' not in r.profile.notes
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          console.log error if error
          for department in record.departments
            if department.checking.finished.name is 'test' #and department.name is '生化检验'
              console.log department.name, department.checking.finished.name, barcode
          callback()
          #record.save callback
    console.log tasks.length
    async.parallelLimit tasks, 1000, (error) ->
      console.log if error then error else '成功'
      process.exit()
