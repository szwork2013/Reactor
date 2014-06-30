models = require '../models'
_ = require 'underscore'
fs = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'appeared': '2013-09-23'})
  .exec (error, records) ->
    count = 0
    str = ''
    for record in records
      images = record.images.filter (image) -> image.tag is '超声影像'
      if images.length > 10
        console.log record.barcode, record.appeared
    process.exit()
