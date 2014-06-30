fs = require 'fs'
raw = fs.readFileSync('./hls.csv').toString()
raw = raw.split('\n').filter((x) -> x.trim())
raw = raw.map (line) -> line.split(',')
for entry in raw
  entry[1] = entry[1].replace entry[0], ''
undup = raw.filter (entry) -> not raw.some (entry_1) -> entry_1 isnt entry and entry_1[1] is entry[1]
console.log undup.length
dic = {}
for entry in undup
  dic[entry[1]] =
    division: entry[2]
    employee_id: entry[0]

mongodb = require 'mongodb'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.find({'profile.source': '和利时'}).toArray  (err, docs) ->
    mismatch = docs.filter((record) -> not record.profile.name.match(/测试/) and not dic[record.profile.name]).map((r) -> r.profile.name + ',' + (r.profile.division or '') + ',' + (r.profile.notes.filter((note) -> note.match /采血号/)[0] or ''))
    console.log name for name in mismatch
    return
    
    docs = docs.filter (record) -> dic[record.profile.name]
    # process.exit()
    # return
    async.parallel docs.map (record) ->
      (callback) ->
        record.profile.division = dic[record.profile.name].division
        record.profile.notes = record.profile.notes.filter (note) -> not note.match /员工编号/
        record.profile.notes.push '员工编号: ' + dic[record.profile.name].employee_id
        # console.log record.samplings.length
        # records.
        records.findAndModify {barcode: record.barcode}, {}, record, (error, res) ->
          console.log error
          callback()
        # record.save callback
    , (error, result) ->
      console.log error, result
      console.log "FINISHED"

