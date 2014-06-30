models = require '../models'
_      = require 'underscore'

models 'hswk.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'field_complete.date_string': '2013-12-28'})
  .select('barcode paper_report profile')
  .exec (error, records) ->
    return console.log error.stack if error
    console.log records.length, 'count'
    results = []
    for record in records
      console.log record.barcode, record.paper_report, record.profile.notes
      console.log record.barcode if record.profile.notes.some((note) -> note.match(/电子报告/))
    process.exit()
