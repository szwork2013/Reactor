models = require '../models'
_ = require 'underscore'
fs = require 'fs'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  Record.find({'profile.source': '中国科学院大学（入学体检）'})
  .select('profile orders barcode departments')
  .exec (error, records) ->
    for record in records
      console.log record.barcode if not record.departments?.length or record.departments.every (department) ->
        department.items.every (item) -> item.status is '未完成'
    process.exit()
