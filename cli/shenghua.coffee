models = require '../models'
_ = require 'underscore'
fs = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'samplings.sample.date_string': '2013-09-13', 'samplings.tag': '生化'})
  .exec (error, records) ->
    records = records.filter (r) -> not r.profile.name.match /测试/
    count = 0
    str = ''
    for record in records
      found_sample = _.find record.samplings, (s) -> s.sample.date_string is '2013-09-13' and s.tag is '生化'
      if found_sample
        for department in record.departments
          if department.name is '生化检验' and department.status is '已完成'
            count += 1
            str += record.barcode + '01' + '\n'
    console.log count, 'count'
    fs.writeFileSync 'shenghua.csv', str, 'utf-8'
    process.exit()
