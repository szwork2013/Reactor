models = require '../models'
_      = require 'underscore'
fs     = require 'fs'

barcodes = ['10000746', '10023687'] # _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  global.websockets = {}
  barcodes = ['10032697']
  tasks = barcodes.map (barcode) ->
    (callback) ->
      Record.barcode barcode, (error, record) ->
        return callback() unless record
        for department in record.departments
          if department.name is '血常规'
            department.items = department.items.filter((item) -> item.status isnt '未完成')
        record.save callback
  async.parallel tasks, (error) ->
    console.log if error then error else '成功'
    #process.exit()
