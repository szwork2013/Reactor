moment = require "moment"
_      = require "underscore"
models = require '../models'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record, Department} = models
  Record.findOne(barcode: '10002734')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    department = record.departments.id '270000000000000000000000'
    department.items.remove department.items.id '270000000000000000000013'
    record.save (error) ->
      console.log error.stack if error
      process.exit()
