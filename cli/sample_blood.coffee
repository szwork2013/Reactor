models   = require '../models'
_        = require 'underscore'
fs       = require 'fs'
async    = require 'async'
barcodes = fs.readFileSync('../log/0905').toString().split('\n').filter((x) -> x)
models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  tasks = barcodes.map (barcode) ->
    (callback) ->
      Record.barcode barcode, {}, (error, record) ->
        console.log barcode
        for sampling in record.samplings
          sampling.sample =
            date_string: '2013-09-05'
            date_number: Date.now()
          sampling.status = '已采样'
        record.save callback
  async.series tasks
