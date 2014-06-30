async   = require 'async'
models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({appeared:{'$gte': '2014-02-17'}})
  .select('barcode')
  .exec (error,records) ->
    return console.log error.stack if error
    barcodes = _.pluck records, 'barcode'
    conditions = []
    count = 0
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.findOne('barcode': barcode)
          .select('departments')
          .exec (error,record) ->
            return console.log error.stack if error
            fsk_department = _.find record.departments, (d) -> d.name is '放射科'
            if fsk_department
              for item in fsk_department.items
                if item.name is '胸部'
                  count += 1
                  for condition in item.conditions
                    found_condition = _.find conditions, (condition_) ->
                      condition_.name is condition.name
                    if found_condition
                      found_condition.count += 1
                    else
                      conditions.push {name: condition.name, count:1}
             callback()
    async.parallelLimit tasks,8,(error) ->
      console.log error if error
      conditions = conditions.sort((a,b) -> if a.count > b.count then -1 else 1)
      console.log conditions, 'conditions',count
      process.exit()
