models = require '../models'
_      = require 'underscore'
fs     = require 'fs'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.barcode process.argv[2], {paid_all:on}, (error, record) ->
    image = record.images.id process.argv[3]
    record.images.remove image
    record.save (error) ->
      console.log error
      process.exit()
