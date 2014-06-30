models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.barcode process.argv[2], (error, record) ->
    return process.exit()  unless record
    fsk = _.find record.departments, (d) -> d.name is '放射科'
    for item in fsk.items
      item.description = undefined
      item.normal = undefined
      item.checking = undefined
      item.conditions = []
    fsk.checking = undefined
    record.save (error, record) ->
      console.log error if error
      process.exit()
