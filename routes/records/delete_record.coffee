_ = require 'underscore'
redis = require "node-redis"
redis_client = redis.createClient()

publish = (topic, send_data) ->
  console.log topic, send_data
  redis_client.publish topic, JSON.stringify send_data

app.delete '/records/:barcode', authorize('mo', 'admin'), (req, res) ->
  {Record}  = req.models
  {barcode} = req.params
  Record.findOne(barcode: barcode)
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 403, {title: '不存在', message: '客人档案不存在。'}  unless record
    return res.send 403, {title: '存在付款项目', message: '当客人存在已付费项目时，不能删除。'} if record.orders.some((order) -> order.paid)
    return res.send 403, {title: '客人已到场', message: '已到场的客人不能删除。'} if record.status isnt '未到场'
    # TODO:Delete middleware
    Record.remove {barcode: barcode}, (error) ->
      return res.send 500, error.stack if error
      {barcode, status, profile, departments} = record
      data =
        barcode: barcode
        name:    profile.name
        sex:     profile.sex
        age:     profile.age
        status:  status
        check_date: profile.check_date
        unchecked: []
        checked: []
      host = req.host.toUpperCase()
      for department in departments
        data.department = department.name
        publish "#{host}:CHECK_SITUATIONS_CHANGE", {names: [department.name], transfer_data: [data]}
      publish "#{host}:CHECK_SITUATIONS_CHANGE", {names: ['体检中心'], transfer_data: [data]}
      res.send {}
