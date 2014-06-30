fairy = require('fairy').connect()
summarization = fairy.queue 'summarization'
# console.log ["hswkzkfy.healskare.com", process.argv[2]]
fs = require 'fs'
_ = require 'underscore'
barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)
# barcodes = ['10007806']
for barcode in barcodes
  summarization.enqueue ["test.healskare.com", barcode], (err, res) ->
    process.exit()
