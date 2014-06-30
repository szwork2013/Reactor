models = require '../models'
_ = require 'underscore'
fs = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'appeared': {'$gte': process.argv[2]}})
  .exec (error, records) ->
    records = records.filter (r) -> not r.profile.name.match /测试/
    count = 0
    str = ''
    for record in records
      for department in record.departments
        if department.name is '生化检验'
          for item in department.items
            console.log record.barcode, item.name, item.value if item.name is '球蛋白'
    process.exit()
