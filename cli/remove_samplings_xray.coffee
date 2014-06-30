fs = require 'fs'
_  = require 'underscore'
mongodb = require 'mongodb'
async = require 'async'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.find({'profile.source': '电子六所'}).toArray  (err, docs) ->
    console.log docs.length
    docs = docs.filter (record) ->
      record.profile.notes.some (note) ->
        match = note.match(/采血号/)
        # match and 167 <= +match[1] <= 287
    for record in docs
      console.log record.barcode
    # process.exit()
    # return
    async.parallel docs.map (record) ->
      (callback) ->
        record.samplings = [] # record.samplings.filter (sampling) -> sampling.name isnt '放射科影像' and sampling._id
        # console.log record.samplings.length
        # records.
        records.findAndModify {barcode: record.barcode}, {}, record, (error, res) ->
          console.log error
          callback()
        # record.save callback
    , (error, result) ->
      console.log error, result
      console.log "FINISHED"
