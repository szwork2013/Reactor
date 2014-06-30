_       = require "underscore"
request = require "superagent"
{exec} = require 'child_process'

app.get '/status/:file', authorize('doctor', 'admin'), (req, res) ->
  console.log req.params.file, __dirname + '/../../cli'
  exec "coffee daily_status.coffee #{req.params.file}", {cwd: __dirname + '/../../cli'}, (error, stdout, stderr) ->
    return res.send {} if error
    stdout = stdout.split('\n').filter((line) -> line).sort (a, b) ->
      a = a.substr(8, 10).trim()
      b = b.substr(8, 10).trim()
      seq_a = a.match /(\d+)\-(?:\D*)(\d+)/
      seq_b = b.match /(\d+)\-(?:\D*)(\d+)/
      if seq_a and seq_b
        return +1 if +seq_a[1] > +seq_b[1]
        return -1 if +seq_a[1] < +seq_b[1]
        return +1 if +seq_a[2] > +seq_b[2]
        return -1 if +seq_a[2] < +seq_b[2]
      else
        if seq_a
          return 1
        else if seq_b
          return -1
        return +1 if +a > +b
        return -1 if +a < +b
        0

    res.send "<pre>#{stdout.join('\n')}</pre>"
  return
  {Record, Product, Department} = req.models
  Record.find({'appeared':{'$ne': []}})
  .select('orders barcode profile appeared')
  .exec (error, records) ->
    return res.send 500, error.stack if error
    data = [['编号', '姓名', '性别', '年龄', '套餐', '到场日期']]
    console.log records.length
    for record in records
      order = _.find record.orders, (order) -> order.category is 'package'
      if order and not record.profile.name.match /测试/
        data.push [record.barcode, record.profile.name, record.profile.sex, record.profile.age, order.name, record.appeared[0]]
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: '到场名单', cells: data}]))
    .set('Content-Type', 'text/plain')
    .end (res2) =>
      res.redirect res2.text
