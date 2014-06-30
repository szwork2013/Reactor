fs = require 'fs'
_  = require 'underscore'

app.get '/daily_barcodes/:date', authorize('cashier'), (req, res) ->
  {date} = req.params
  {Record} = req.models
  Record.find({'field_complete.date_string': date})
  .select('profile.notes barcode')
  .exec (err, docs) ->
    return res.send err.stack if err
    str = ''
    docs = docs.sort (a, b) ->
      if a.profile.notes.length > b.profile.notes.length then -1
      else 1
    for doc in docs
      str += doc.barcode
      notes = doc.profile.notes.join(' ')
      if notes
        str += '&nbsp;&nbsp;&nbsp;' + doc.profile.notes.join(' ')
      str += '<br>'
    res.render 'departments', {page: '每日体检编号', str: str}
