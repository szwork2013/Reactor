models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({status: '检查中', 'appeared': {'$gte': '2013-08-21', '$lte': '2013-09-27'}})
  #Record.find({barcode: '10001780'})
  .select('barcode')
  .exec (error, records) ->
    console.log error if error
    console.log records.length
    #records = records.filter (r) -> '外检' not in r.profile.notes
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, paid_all: on, (error, record) ->
          console.log error if error
          for department in record.departments
            if department.name is '免疫检验' #and department.name is '生化检验'
              found_item = _.find department.items, (item) -> item.name is '幽门螺旋杆菌抗体'
              if found_item?.status is '未完成'
                found_item.status = '放弃'
          console.log barcode, 'barcode'
          record.save callback
    console.log tasks.length
    async.parallelLimit tasks, 1000, (error) ->
      console.log if error then error else '成功'
      process.exit()
