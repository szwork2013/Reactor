models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

models 'hswk.healskare.com', (error, models, settings) ->
  global.websockets = {}
  Record = models.Record
  Record.findOne({'barcode': process.argv[2]})
  .exec (error, record) ->
    console.log error if error
    console.log 'before', record.profile.check_date
    record.profile.check_date = process.argv[3]
    record.save (error, record) ->
      console.log error if error
      console.log 'after', record.profile.check_date
      console.log 'ok'
      process.exit()
