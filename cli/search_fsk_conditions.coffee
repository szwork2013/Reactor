async  = require 'async'
models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  conditions_count = {}
  Record.find()
  .select('barcode')
  .exec (error, records) ->
    return console.log error.stack if error
    barcodes = _.pluck records, 'barcode'
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.findOne(barcode: barcode)
        .select('departments')
        .exec (error, record) ->
          return console.log error.stack if error
          fsk_department = _.find record.departments, (d) -> d.name is '放射科'
          if fsk_department
            if fsk_department.appeared >= '2014-02-17'
              for item in fsk_department.items
                for condition in item.conditions
                  conditions_count[condition.name] or= 0
                  conditions_count[condition.name] += 1
          callback()
    async.parallelLimit tasks, 10000, (error) ->
      console.log error if error

      
      console.log conditions_count, 'conditions_count'
      process.exit()
