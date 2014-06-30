models = require '../models'
_ = require 'underscore'
fs = require 'fs'
models 'test.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.barcode process.argv[2], {paid_all:on}, (error, record) ->
    for department in record.departments
      for item in department.items
        if item.name in ['酸碱度', '尿比重']
          item.note = undefined
          item.value = undefined
          item.ut = undefined
          item.lt = undefined
          item.conditions = []
          item.status = '未完成'
          department.status = '未完成'
          console.log item.status
    console.log record.departments
    record.save (error, record) ->
      console.log error
      console.log record, 'record'
      process.exit()
