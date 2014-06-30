models = require '../models'
_ = require 'underscore'
async = require 'async'
models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.barcode '10014695', {}, (error, record) ->
    console.log record.samplings[1]
    record.samplings[1].status = '未采样'
    record.save (error, record) ->
      process.exit()
