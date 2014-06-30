models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'

#summarization.enqueue ["hswk.healskare.com", barcode], (err, res) ->

models 'hswk.healskare.com', (error, models, settings) ->
  Record  = models.Record
  Batch   = models.Batch
  Product = models.Product
  Batch.find({status: 'ongoing'})
  .select('status')
  .exec (error, batches) ->
    return console.log error if error
    #Product.find({'batch': { '$in':  _.pluck(batches, '_id') }})
    Product.find({'batch': '51c05a481e8570b51200000b'})
    .select('_id name configurations._id configurations.name')
    .exec (error, products) ->
      return console.log error if error
      orderids = {}
      ids = []
      for product in products
        for config in product.configurations
          orderids[config._id] = product.name + '_' + config.name
          ids.push config._id
      console.log ids, 'ids'
      console.log orderids, 'orderids'
      tasks = ids.map (id) ->
        (callback) ->
          Product.get_combos_by_orderids [id], (error, combos) =>
            console.log orderids[id] unless '纸质报告' in _.flatten(_.values(combos))
            callback()
      async.series tasks, (error) ->
        console.log if error then error else '成功'
        process.exit()
