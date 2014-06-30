fs       = require 'fs'

app.get '/barcodes', authorize('mo', 'admin'), (req, res) ->
  month = ((new Date).getMonth() + 1).toString()
  month = if month.length is 1 then '0' + month else month
  date  = ((new Date).getDate()).toString()
  date  = if date.length is 1 then '0' + date else date
  date  = month + date
  fs.readFile "#{__dirname}/../../log/#{date}", (error, barcodes) ->
    barcodes = '' if error
    barcodes += ''
    res.render 'barcodes', {page: '客人编号', barcodes: barcodes}
