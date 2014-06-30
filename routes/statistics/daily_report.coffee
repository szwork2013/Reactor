fs = require 'fs'
_  = require 'underscore'

app.get '/daily_report/:date', authorize('cashier'), (req, res) ->
  {date} = req.params
  fs.readFile './log/' + date, 'utf-8', (err, barcodes) ->
    return res.send err if err
    barcodes = _.uniq barcodes.toString().split('\n').filter((barcode) -> barcode)
    {Record} = req.models
    Record.find({barcode: '$in': barcodes})
    .select('profile orders barcode')
    .exec (err, docs) ->
      return res.send err.stack if err
      result = docs.reduce (memo, doc) ->
        memo[doc.profile.source] = memo[doc.profile.source] + 1 or 1
        memo
      , {}
      day = _.last (date.split('/'))
      str = "2013-#{day.substring(0,2)}-#{day.substr(2)}  总计#{barcodes.length}人，其中：<br>"
      str += "<br>"
      for source, count of result
        str += "#{source}：#{count}人<br>"
        company_docs = docs.filter (d) -> d.profile.source is source
        for company_doc in company_docs
          pkg = company_doc.orders.filter((o) -> o.category is 'package')[0]?.name
          pkg = pkg?.match(/（(.*)）$/)?[1] or pkg
          str += pkg + ' ' + company_doc.profile.division + ' ' + company_doc.barcode + ' ' + company_doc.profile.name + ' ' + company_doc.profile.sex + ' ' + company_doc.profile.age + "岁" + ' ' + company_doc.profile.notes?.join(' ') + '<br>'
        str += '<br>'
      res.render 'departments', {page: '每日报告', str: str}
