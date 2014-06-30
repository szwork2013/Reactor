models = require '../models'
_      = require 'underscore'
fs     = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async  = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log Record, 'Record'
  Record.find({'profile.batch': '51c0f5d7d07977891800000e', 'appeared':{'$exists': true}})
  .exec (error, records) ->
    records = records.filter (r) -> not r.profile.name.match /测试/
    count = 0
    str = '编号,部门,姓名,电话,hash_id\n'
    records = records.sort (a, b) -> if a.profile.tel > b.profile.tel then -1 else 1
    for record in records
      str += record.barcode + ',' + (record.profile.division or '') + ',' + record.profile.name + ',' + (record.profile.tel or '') + ',' + (record.profile.hash_id or '') + '\n'
    fs.writeFileSync 'gjqc.csv', str, 'utf-8'
    process.exit()
