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
    records.find({'profile.batch': res[0]._id},{_id: 1, status: 1, 'profile': 1, 'barcode': 1}).toArray (err, records) ->
      # console.log records.length
      for record in records
        console.log "coffee empty_samplings.coffee", record.barcode if record.profile.check_date is '2013-08-28'
      process.exit()
      records = records.filter((r) -> not /测试/.test r.profile.name).sort (a, b) -> if a.barcode > b.barcode then 1 else -1
      console.log "rm -rf #{company}"
      console.log "mkdir #{company}"
      # console.log records.length
      console.log "cp ../../reactor/public/pdfs/reports/#{record.barcode}.pdf #{company}/#{(record.profile.division?.trim() or '其他部门').replace /[\(\)\（\）]/g, ''}_#{record.profile.name.replace /'/g, ""}_#{record.barcode}.pdf" for record in records
      process.exit()
