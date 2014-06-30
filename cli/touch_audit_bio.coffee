models = require '../models'
_      = require 'underscore'
fs     = require 'fs'
async  = require 'async'
moment = require 'moment'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'appeared': {'$lte': '2013-11-23'}, status: {'$ne': '已完成'}})
  .select('barcode')
  .exec (error, records) ->
    return console.log error if error
    barcodes = []
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          console.log error if error
          department = _.find record.departments, (d) ->
            d.name is '生化检验' and d.status is '待审核'
          console.log record.barcode, record.biochemistry.audit, 'before'
          if department
            record.biochemistry.audit =
              _id: '111000000000000000000004'
              name: '李晓明'
              date_number: Date.now()
              date_string: moment().format('YYYY-MM-DD')
          console.log record.barcode, record.biochemistry.audit, 'after'
          record.save callback
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
