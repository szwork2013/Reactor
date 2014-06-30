_       = require "underscore"
request = require "superagent"

app.get '/statistics/:company/appeared_guests', authorize('doctor', 'admin'), (req, res) ->
  {Record, Product, Department} = req.models
  Record.find({'profile.source': req.params.company, 'appeared':{'$ne': []}})
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
