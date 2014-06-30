{exec} = require 'child_process'
company = process.argv[2]
mongodb = require 'mongodb'
ObjectID = mongodb.ObjectID
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  now = Date.now()
  batches = client.collection 'batches'
  records = client.collection 'records'
  batches.find(company: company).sort(_id: -1).limit(1).toArray (err, res) ->
    # console.log res[0]._id
    results = []
    records.find({'profile.batch': res[0]._id},{_id: 1, status: 1, 'profile': 1, 'barcode': 1}).toArray (err, records) ->
      # console.log records.length
      records = records.filter((r) -> not /测试/.test r.profile.name).sort (a, b) -> if a.barcode > b.barcode then 1 else -1
      console.log "rm -rf #{company}"
      console.log "mkdir #{company}"
      # console.log records.length
      results.push "#{(record.profile.division?.trim() or '').replace /[\(\)\（\）]/g, ''}_#{record.profile.name.replace /'/g, ""}_#{record.profile.notes[0] or ''}" for record in records
      results = results.sort (a, b) -> if a > b then 1 else -1
      console.log l for l in results
      process.exit()
