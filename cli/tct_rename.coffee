{exec} = require 'child_process'
company = process.argv[2]
mongodb = require 'mongodb'
ObjectID = mongodb.ObjectID
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  now = Date.now()
  batches = client.collection 'batches'
  records = client.collection 'records'
  fs.readdir './机关TCT', (err, files) ->
    console.log files.length
    tasks = files.map (file) ->
      (callback) ->
        barcode = file.split('-')[0].substring(0, 8)
        name = file.split('-')[1].trim()
        # console.log barcode
        records.findOne {barcode: barcode}, (error, record) ->
          console.log "MISSING",error, barcode, file unless record
          return callback() unless record
          # console.log 1
          console.log "cp 机关TCT/#{file} TCT/#{record.profile.division?.replace(/\s/g, '').trim() or '无部门'}_#{barcode}_#{name}"
          callback()
    console.log tasks.length
    async.series tasks, (error) ->
      console.log error
      #console.log "EXIT"
      process.exit()
    return
  return
  batches.find(company: company).sort(_id: -1).limit(1).toArray (err, res) ->
    # console.log res[0]._id
    # barcodes = fs.readFileSync(__dirname + '/../log/hls').toString()
    # barcodes = barcodes.split('\n').filter((x) -> x)
    
    records.find({'profile.batch': res[0]._id},{_id: 1, status: 1, 'profile': 1, 'barcode': 1}).toArray (err, records) ->
      # console.log records.length
      # records.find({'profile.batch': res[0]._id},{_id: 1, status: 1, 'profile': 1, 'barcode': 1}).toArray (err, records) ->
      # console.log records.length
      records = records.filter((r) -> not /测试/.test r.profile.name).sort (a, b) -> if a.barcode > b.barcode then 1 else -1
      console.log "rm -rf #{company}"
      console.log "mkdir #{company}"
      blood_seq = (record) ->
        result = _.find(record.profile.notes, (note) -> note.match(/采血号|抽血号/))?.replace(/采血号[:：]?|抽血号[：:]?/, '').trim().replace(/\-/g,'_').replace(/\s/g,'') or ''
        result = result.split('_').map (x) ->
          y = '000' + x
          y.substr y.length - 3, 3
        result.join('_')
      # console.log records.length
      # #{(record.profile.division?.trim() or '其他部门').replace /[\(\)\（\）]/g, ''}
      console.log "cp ../../reactor/public/pdfs/reports/#{record.barcode}.pdf #{company}/#{(record.profile.division?.trim() or '其他部门').replace(/[\(\)\（\）]/g, '').replace(/\s/g, '').trim()}_#{record.profile.name.replace(/'/g, "").trim()}_#{record.barcode}.pdf" for record in records
      # console.log "cp ../../reactor/public/pdfs/reports/#{record.barcode}.pdf #{company}/#{blood_seq record}_#{record.barcode}.pdf" for record in records
      # console.log record.barcode for record in records
      process.exit()
