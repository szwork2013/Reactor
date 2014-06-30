models = require '../models'
_      = require 'underscore'
fs     = require 'fs'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.barcode process.argv[2], {paid_all:on}, (error, record) ->
    department = record.departments.id '220000000000000000000000'
    department.status = '未完成'
    for item in department.items
      item.status = '未完成'
      item.note = undefined
    record.save (error) ->
      console.log error
      process.exit()
