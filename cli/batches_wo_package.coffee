mongodb = require 'mongodb'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  Batch = client.collection 'batches'
  Product = client.collection 'products'
  Batch.find().toArray (error, batches) ->
    counter = batches.length
    for batch in batches
      do (batch) ->
        Product.find({batch:batch._id}).toArray (error, products) ->
          console.log "大套餐缺失", batch._id, batch.company unless (products.length is 1)
          console.log "小套餐缺失", batch._id, batch.company unless (products[0].configurations.length)
          process.exit() unless --counter
