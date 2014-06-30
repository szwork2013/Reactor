models = require '../models'
fs     = require 'fs'
barcodes = [
  '10025775'
]

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'barcode': {'$in': barcodes}})
  .exec (error, records) ->
    return console.log error.stack if error
    fs.writeFileSync './export_json/records.json', JSON.stringify(records), 'utf-8'
    process.exit()
