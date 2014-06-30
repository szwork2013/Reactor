mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'
async        = require 'async'
models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  barcodes = process.argv[2..]
  tasks = barcodes.map (barcode) ->
    (callback) ->
      Record.barcode barcode.substring(0, 8), {paid_all: on}, (error, record) ->
        return callback error if error
        return callback "无档案" unless record
        record.samplings.remove barcode
        record.save callback
  async.series tasks, (error, result) ->
    console.log error
    process.exit()
