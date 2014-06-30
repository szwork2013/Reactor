request      = require 'superagent'

app.get '/combos.xls', authorize('doctor', 'admin'), (req, res) ->
  {Product} = req.models
  Product.find({category: 'combo'})
  .select('configurations.name configurations.mean configurations.price')
  .sort('order')
  .exec (error, combos) ->
    return res.send 500, error.stack if error
    datas = []
    datas.push [
      '组合名称'
      '价格'
      '意义'
    ]
    for combo in combos
      for config in combo.configurations
        datas.push [config.name, config.price, config.mean]
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: '组合列表', cells: datas}]))
    .set('Content-Type', 'text/plain')
    .end (error, res2) =>
      res.redirect res2.text
