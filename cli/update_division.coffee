models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'images.tag': '超声影像', appeared: {'$gte': '2013-09-07'}})
  .select('barcode images')
  .exec (error, records) ->
    return console.log error if error
    barcodes = []
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          console.log error if error
          console.log record.images, 'before'
          images = record.images.filter (image) -> image.tag is '超声影像'
          record.images = record.images.filter (image) -> image.tag isnt '超声影像'
          images = images.sort (a, b) -> if a._id.valueOf() > b._id.valueOf() then 1 else -1
          start = 0
          second = (object_id) ->
            object_id.getTimestamp().valueOf() / 1000
          while start < images.length
            images = images.filter (image, index) -> second(image._id) - second(images[start]._id) > 10 or index <= start
            start++
          for image in images
            record.images.push image
          console.log barcode, record.images, 'after'
          record.save callback
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      console.log 111111
      process.exit()
