models = require '../models'
_      = require 'underscore'
fs     = require 'fs'

try
  barcodes = _.uniq fs.readFileSync("./" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
catch
  barcodes = [process.argv[2]]
console.log barcodes.length
# barcodes = ['10000746', '10023687'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  # global.websockets = {}
  console.log barcodes.length
  tasks = barcodes.map (barcode) ->
    (callback) ->
      Record.barcode barcode, (error, record) ->
        return callback() unless record
        console.log barcode
        record.save callback
  async.parallelLimit tasks, 8, (error) ->
    console.log if error then error else '成功'
    process.exit()
