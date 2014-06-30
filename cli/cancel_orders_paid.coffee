models = require '../models'
_      = require 'underscore'
fs     = require 'fs'

barcodes = ['10000746', '10023687'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  barcode = process.argv[2]
  console.log barcode
  Record.barcode barcode, (error, record) ->
    return console.log error unless record
    for order in record.orders
      order.paid = 0
    record.payments = []
    record.save (error, record) ->
      console.log if error then error else '成功'
      process.exit()
