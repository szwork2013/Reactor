fs = require 'fs'
_  = require 'underscore'
mongodb = require 'mongodb'

barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode).map((x) -> x.substr(0, 8))
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.find({barcode: '$in': barcodes}, {profile:1, departments:1, orders: 1, barcode:1}).toArray  (err, docs) ->
    for {departments, barcode, profile} in docs
      # console.log barcode
      uncomplete_departments = departments.filter (d) -> d.status is '待检验' or d.status is '未完成'
      console.log barcode, ((profile.notes.join(',')) + '               ').substring(0, 10), _.pluck(uncomplete_departments, 'name').join()
    process.exit()
