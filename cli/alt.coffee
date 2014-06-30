models = require '../models'
_ = require 'underscore'
fs = require 'fs'
barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
async = require 'async'
models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  tasks = barcodes.map (barcode) ->
    console.log barcode
    (callback) ->
      Record.barcode barcode, {paid_all:on}, (error, record) ->
        biochem = record.departments.filter((d) -> d.name is '生化检验')[0]
        alt = biochem.items.filter((i) -> i.abbr is 'ALT')[0]
        if alt
          index = biochem.items.indexOf alt
          biochem.items.splice index, 1
          biochem.items.splice 0, 0, alt
        console.log alt.value
        record.save callback
  console.log tasks.length
  async.parallel tasks, (error) ->
    console.log if error then error else '成功'
    process.exit()
