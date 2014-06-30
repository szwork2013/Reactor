models = require '../models'
_ = require 'underscore'
fs = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'test.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'appeared.0': {'$gte': '2013-06-02'}})
  .select('barcode profile.name departments')
  .sort('barcode')
  .exec (error, records) ->
    console.log records.length, 'count'
    records = records.filter (r) -> not r.profile.name.match /测试/
    count = 0
    str = ''
    items = {}
    for record in records
      for department in record.departments
        if department.name is '免疫检验'
          for item in department.items
            if item.status is '已完成'
              items[item.name] or = 0
              items[item.name] += 1
    for name, count of items
      str += name + ',' + count + '\n'
    fs.writeFileSync 'my.csv', str, 'utf-8'
    process.exit()
