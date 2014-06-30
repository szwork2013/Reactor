models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'appeared': {'$gte': '2013-08-01', '$lte': '2013-12-26'}, 'departments.checking.finished.name': '郭学'})
  .select('profile images barcode')
  .exec (error, records) ->
    return console.log error.stack if error
    records = records.filter (record) -> not record.profile.name.match(/测试/) and '外检' not in record.profile.notes
    console.log records.length, 'count'
    records = records.filter (record) -> record.images.filter((image) -> image.tag?.match(/胸部/)).length
    console.log records.length, 'count'
    data = {}
    for record in records
      data[record.profile.source] or = 0
      data[record.profile.source] += 1
    console.log data
    process.exit()
