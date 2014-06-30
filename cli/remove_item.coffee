models = require '../models'
_      = require 'underscore'
fs     = require 'fs'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.barcode '10023533', {paid_all:off}, (error, record) ->
    for department in record.departments
      if department.name is '免疫检验'
        found_item1 = _.find department.items, (item) -> item._id.toString() is '280000000000000000000025'
        found_item2 = _.find department.items, (item) -> item._id.toString() is '280000000000000000000026'
        found_item3 = _.find department.items, (item) -> item._id.toString() is '280000000000000000000027'
        found_item4 = _.find department.items, (item) -> item._id.toString() is '280000000000000000000028'
        found_item5 = _.find department.items, (item) -> item._id.toString() is '280000000000000000000029'
        department.items = department.items.remove found_item1
        department.items = department.items.remove found_item2
        department.items = department.items.remove found_item3
        department.items = department.items.remove found_item4
        department.items = department.items.remove found_item5
    record.save (error) ->
      process.exit()
