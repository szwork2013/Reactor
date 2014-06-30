mongodb = require 'mongodb'
fuzzyCompanyName = process.argv[2]
quondamStatus = process.argv[3]
expectedStatus = process.argv[4]
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  client.collection('batches').find({company:{$regex:fuzzyCompanyName},status:quondamStatus}).toArray (err, docs) ->
    console.log 'Past data in DB --> '
    console.log docs
    client.collection('batches').update {company:{$regex:fuzzyCompanyName},status:quondamStatus}, {$set:{status:expectedStatus}},{multi: true}, (err, takeEffect) ->
      console.log err if err
      console.log 'Take effect --> ',takeEffect 
      console.log "DONE"
      process.exit()
