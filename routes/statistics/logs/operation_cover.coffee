_ = require "underscore"
{spawn, exec} = require 'child_process'
fs = require 'fs'
moment  = require "moment"
#app.get '/statistics/logs/operation_log.pdf', authorize('doctor', 'admin'), (req, res) ->
app.get /^\/statistics\/logs\/operation_log\.[pdf]+$/, authorize('doctor', 'admin'), (req, res) ->
  #文件名称
  file_name = moment().format('YYYY-MM-DD')
  #保存路径 
  file_path = "/public/pdfs/logs/#{file_name}.pdf"
  #0:输入地址，1:输出路径
  options = [
    "#{req.protocol}://#{req.get('host')}#{req.path.substr(0,req.path.indexOf('.'))}"
    "#{__dirname}/../../..#{file_path}"
  ]
  #返回客户端已生成文件方法
  send_pdf_file = (err) =>
    return res.send err if err
    res.set "Content-Disposition", "inline; filename*=utf-8''#{encodeURIComponent(file_name)}.pdf"
    res.sendfile(".#{file_path}")
  #判读pdf文件是否已经存在
  fs.exists ".#{file_path}", (exists) ->
    #如果该pdf存在且路由中含有new参数
    if exists and not req.query.new?
      send_pdf_file()
    else
      exec 'osascript html2pdf2 ' + options.join(' '), {cwd: __dirname + '/../../../utils', timeout:5000}, send_pdf_file

app.get '/statistics/logs/operation_log', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  week_arr = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六']
  date = moment().format('YYYY-MM-DD')
  format_date= moment().format('YYYY-MM-DD')
  week = week_arr[moment().format('d')]
  Record.find({appeared: date})
  .select('barcode appeared profile.source ')
  #.select('orders.paid orders.histories')
  .select('credits')
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
      {appeared, profile, credits} = record
      #console.log JSON.stringify(credits), 'dndndndndndndndn'
      result.appeared += 1
      if appeared.length is 1
        result.first_appeared +=1
        result.individual_count += 1 if profile.source is '个检'
        if profile.source isnt '个检'
          result.group[profile.source] or = 0
          result.group[profile.source] += 1
          
      credits = _(credits).groupBy('product_id')
      #记账收入
      result.tally_income += _(credits)
      .reduce (memo, credits) ->
        #for credit in credits
        #console.log JSON.stringify(credits), 'cccccccccc'
        #console.log _(credits).last().price, 'ddddddddddddd'
        #console.log _(@).last().price, 'ffffffff'
        memo += _(credits).last().price if _(credits).last().type is '记账'
        memo
      , 0
      #记账退费
      result.tally_refund += _(credits)
      .reduce (memo, credits) ->
        memo -= _(credits).last().price if _(credits).last().type is '退账'
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
      #res.send result
      res.render 'op_log', op:result
