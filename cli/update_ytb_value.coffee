models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find({'profile.batch': '51c0f5d7d07977891800000e'})
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
          console.log 11111111
          for department in record.departments
            for item in department.items
              if item.name is '腰臀比'
                yw = _.find department.items, (item) -> item.name is '腰围'
                tw = _.find department.items, (item) -> item.name is '臀围'
                if item.value is 'NaN'
                  item.value = undefined
                  item.status = '未完成'
                else
                  item.value = parseFloat(yw.value/tw.value).toFixed(2)
              if item.name is '体重指数'
                sg = _.find department.items, (item) -> item.name is '身高'
                tz = _.find department.items, (item) -> item.name is '体重'
                if item.value is 'NaN'
                  item.value = undefined
                  item.status = '未完成'
                else
                  item.value = parseFloat(tz.value/((sg.value/100)*(sg.value/100))).toFixed(2)
          record.save callback
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
