_       = require "underscore"
{spawn, exec} = require 'child_process'
moment  = require "moment"

app.get '/statistics/operation_log.pdf', authorize('doctor', 'admin'), (req, res) ->
  options = [
    "#{req.protocol}://#{req.get('host')}#{req.path.substr(0,req.path.indexOf('.'))}"
    "#{__dirname}/../../public/pdfs/logs/#{moment().format('YYYY-MM-DD')}.pdf"
  ]
  grep = exec 'osascript html2pdf2 ' + options.join(' '), {cwd: __dirname + '/../../utils', timeout:5000}, (err, stdout, stderr) =>
    return res.send err if err
    res.set "Content-Disposition", "inline; filename*=utf-8''#{moment().format('YYYY-MM-DD')}.pdf"
    res.sendfile("./public/pdfs/logs/#{moment().format('YYYY-MM-DD')}.pdf")

app.get '/statistics/operation_log', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  week_arr = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六']
  date = moment().format('YYYY-MM-DD')
  format_date= moment().format('YYYY-MM-DD')
  week = week_arr[moment().format('d')]
  Record.find({appeared: date})
  .select('barcode appeared profile.source ')
  .select('orders.paid orders.histories')
  .exec (error, records) ->
    return res.send 500, error.stack if error
    result =
      date:format_date
      week:week
      appeared: 0
      first_appeared: 0
      individual_count: 0
      group: {}
      tally_income: 0
      tally_refund: 0
      actual_income: 0
      actual_refund: 0
    for record in records
      {appeared, profile, orders} = record
      result.appeared += 1
      if appeared.length is 1
        result.first_appeared +=1
        result.individual_count += 1 if profile.source is '个检'
        if profile.source isnt '个检'
          result.group[profile.source] or = 0
          result.group[profile.source] += 1
      result.tally_income += orders
      .filter((order) -> order.paid is 2)
      .reduce (memo, order) ->
        histories = order.histories.filter((history) -> history.date_string is date)
        if histories.length > 1
          history = histories[histories.length - 1]
          console.log history
          memo += if history.actual_price? then history.actual_price else history.price
          console.log '------------------------------------------------------------->>>>'
          console.log history.actual_price?, history.price?,order.actual_price?
        console.log '5674839023984578493047548394'
        console.log JSON.stringify(order)
        memo
      , 0
      result.tally_refund += orders
      .filter((order) -> order.paid is -1)
      .reduce (memo, order) ->
        console.log 'NNNNNNNNNNNNNNNNNNNNN'
        histories = order.histories.filter((history) -> history.date_string is date)
        history = histories[histories.length - 1]
        console.log history.actual_price?, '555555555555'
        memo += if history.actual_price? then history.actual_price else history.price
        memo
      , 0
    commands = []
    commands.push '$match': 'payments.staff.date_string': date
    commands.push '$unwind': '$payments'
    commands.push '$match': 'payments.staff.date_string': date
    commands.push
      '$project':
        'category': '$payments.category'
        'amount': '$payments.amount'
    Record.aggregate commands, (error, payments) ->
      return res.send 500, error.stack if error
      for payment in payments
        result.actual_income += payment.amount if payment.category is 'payment'
        result.actual_refund += payment.amount if payment.category is 'refund'
      # res.send result
      res.render 'op_log', op:result
