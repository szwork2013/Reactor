models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({appeared:{'$gte': '2013-11-01'}})
  .select('departments images barcode')
  .exec (error, records) ->
    return console.log error.stack if error
    for record in records
      fsk = _.find record.departments, (d) -> d.name is '放射科' and d.status is '已完成'
      if fsk
        images = record.images.filter (image) -> image?.tag?.match(/放射/)
        console.log record.barcode unless images.length
    process.exit()
