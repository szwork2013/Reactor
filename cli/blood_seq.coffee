mongodb = require 'mongodb'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  Batch = client.collection 'batches'
  Record = client.collection 'records'
  Batch.findOne {company: process.argv[2]}, (error, batch) ->
    # console.log batch._id
    Record.find({'profile.batch':batch._id}).toArray (error, records) ->
      console.log record.profile.name, ",", record.barcode, ",", "'" + record.profile.notes[0] for record in records.sort (a, b) ->
        seq_a = a.profile.notes[0]?.match /(\d+)\-(\d+)/
        seq_b = b.profile.notes[0]?.match /(\d+)\-(\d+)/
        if seq_a and seq_b
          return +1 if +seq_a[1] > +seq_b[1]
          return -1 if +seq_a[1] < +seq_b[1]
          return +1 if +seq_a[2] > +seq_b[2]
          return -1 if +seq_a[2] < +seq_b[2]
        else
          return +1 if +a.profile.notes[0] > +b.profile.notes[0]
          return -1 if +a.profile.notes[0] < +b.profile.notes[0]
          0
      process.exit()
