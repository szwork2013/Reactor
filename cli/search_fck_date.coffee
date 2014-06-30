models = require '../models'
_      = require 'underscore'

models 'test.healskare.com', (error, models, settings) ->
  {Record} = models

  Record.find({'departments.checking.finished.date_number': {'$gte': 1380269923334, '$lte': 1380269943334}})
  .select('images barcode')
  .exec (error, records) ->
    return console.log error.stack if error
    console.log _.pluck records, 'barcode'
    jz = []
    for record in records
      for image in record.images
        if image.tag.match(/(颈椎|胸部)/)
          jz.push record.barcode
    console.log _.uniq jz
    process.exit()
