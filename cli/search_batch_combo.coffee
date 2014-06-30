models = require '../models'
_      = require 'underscore'
async  = require "async"

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({appeared:{'$ne': []}, 'profile.batch': '521aed291f27f6ca7e000008'})
  .select('appeared barcode profile.name orders')
  .exec (error, records) ->
    return console.log error.stack if error
    console.log records.length, 'count'
    str = '编号, 姓名, 增项, 价格, 到场时间\n'
    for record in records
      combos = record.orders.filter((order) -> order.category is 'combo')
      if combos.length
        for combo in combos
          str += record.barcode + ',' + record.profile.name + ',' + combo.name + ',' + combo.price + ',' + record.appeared[0] + '\n'
    fs.writeFileSync 'batch_combos.csv', str, 'utf-8'
    process.exit()
