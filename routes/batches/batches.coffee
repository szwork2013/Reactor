_           = require "underscore"

app.get '/batches2', authorize('cashier'), (req, res) ->
  step1 = new Date
  {skip, limit, fields, filter, enterprise} = req.query
  req.models.Batch.find()
  .select('_id company')
  .exec (error, batches) ->
    return res.send 500, error.stack if error
    str = ''
    for batch in batches
      str += batch._id + ' ' + batch.company + '<br>'
    res.render 'departments', {page: '批次信息', str: str}
