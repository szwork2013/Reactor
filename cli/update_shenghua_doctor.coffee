models = require '../models'
_ = require 'underscore'
fs = require 'fs'
async = require 'async'
#barcodes = _.uniq fs.readFileSync("../log/" + process.argv[2]).toString().split('\n').filter((barcode) -> barcode)

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  Record.find()
  .exec (error, records) ->
    console.log error if error
    for record in records
      for department in record.departments
        if department.checking.finished.name is 'test'
          console.log 'test', record.barcode
        #department.checking.finished.name = '李晓明'
    #record.save (error) ->
    #console.log error if error
    #  process.exit()
