models = require '../models'
_ = require 'underscore'
fs = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'profile.source': '网络中心', appeared: '2013-09-10'})
  .select('profile orders barcode')
  .exec (error, records) ->
    count = 0
    for record in records
      order = record.orders[0]
      gt = order.name.match(/以上/)
      lt = order.name.match(/以下/)
      if gt and record.profile.age < 35 or (lt and record.profile.age > 35)
        count += 1
        console.log order.name , record.profile.age, record.barcode
    console.log count, 'count' 
    process.exit()
