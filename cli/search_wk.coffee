models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'appeared': {'$gte': '2013-11-27', '$lte': '2013-11-31'}, images: []})
  .select('barcode departments')
  .exec (error, records) ->
    return console.log error.stack if error
    for record in records
      for department in record.departments
        if department.status is '已完成' and department.name is '放射科'
          console.log record.barcode, 'barcode'
    process.exit()
