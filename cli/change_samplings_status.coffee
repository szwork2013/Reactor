mongodb = require 'mongodb'
barcode = process.argv[2]
appeared = process.argv[3]
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  client.collection('records').findOne {barcode: barcode}, {}, (err, doc) ->
    doc.appeared = [appeared]
    doc.profile.check_date = appeared
    console.log doc.appeared
    client.collection('records').findAndModify {barcode: barcode}, {}, doc, (err, doc) ->
      console.log err if err
      console.log "DONE"
      process.exit()
