models = require '../models'
_      = require 'underscore'
fs     = require 'fs'
async  = require 'async'
models 'hswk.healskare.com', (error, models, settings) ->
  Product = models.Product
  console.log "A"
  Product.find({category: 'package'})
  .exec (error, products) ->
    ids = _.pluck products, '_id'
    tasks = ids.map (id) =>
      (callback) =>
        Product.findOne({_id: id})
        .exec (error, product) =>
          console.log error if error
          product.save callback
    async.parallel tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
