fs       = require 'fs'

app.put '/barcodes', authorize('mo', 'admin'), (req, res) ->
  month = ((new Date).getMonth() + 1).toString()
  month = if month.length is 1 then '0' + month else month
  date  = ((new Date).getDate()).toString()
  date  = if date.length is 1 then '0' + date else date
  date  = month + date
  fs.writeFileSync "#{__dirname}/../../log/#{date}", req.body.barcodes
  res.send {}
