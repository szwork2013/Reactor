models = require '../models'
_      = require 'underscore'
async  = require "async"

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'field_complete.date_string': {'$gte': '2013-12-01', '$lte': '2013-12-25'}})
  .select('samplings barcode')
  .exec (error, records) ->
    return console.log error.stack if error
    guests = []
    for record in records
      _tct = _.find record.samplings, (s) -> s.name is 'TCT标本' and s.status is '已采样'
      if _tct
        guests.push barcode: record.barcode
    str = '编号\n'
    for {barcode} in guests
      str += barcode + '\n'
    fs.writeFileSync 'barcodes.csv', str, 'utf-8'
    process.exit()
