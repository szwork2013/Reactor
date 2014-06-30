{exec} = require 'child_process'
company = process.argv[2]
mongodb = require 'mongodb'
ObjectID = mongodb.ObjectID
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  now = Date.now()
  batches = client.collection 'batches'
  records = client.collection 'records'
  batches.find(company: company).sort(_id: -1).limit(1).toArray (err, res) ->
    records.find({'profile.batch': res[0]._id},{_id: 1, orders: 1, status: 1, 'profile': 1, 'barcode': 1}).toArray (err, records) ->
      for record in records
        for order in record.orders
          # if order.category is 'package' and order.paid is 1
          #   console.log record.profile.name, order.name, '自费'
          # if order.category is 'package' and order.paid is 2
          #   console.log record.profile.name, order.name, '记帐', order.price
          if order.category is 'combo' and order.paid isnt 0
            console.log record.barcode, record.profile.name, order.name, (if order.paid is 1 then '自费' else '记帐'), order.price
      process.exit()
