fs = require 'fs'
mongodb = require 'mongodb'
_ = require 'underscore'

mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.find({'profile.source': '机关'}, {profile:1, orders: 1, barcode:1}).toArray (err, docs) ->
    console.log doc.profile.batch for doc in docs
    process.exit()
    result = docs.reduce (memo, doc) ->
      memo[doc.profile.source] = memo[doc.profile.source] + 1 or 1
      memo
    , {}
    day = _.last (process.argv[2].split('/'))
    console.log "2013-#{day.substring(0,2)}-#{day.substr(2)}  总计#{barcodes.length}人，其中："
    console.log ""
    for source, count of result
      console.log "#{source}：#{count}人"
      company_docs = docs.filter (d) -> d.profile.source is source
      for company_doc in company_docs
        pkg = company_doc.orders.filter((o) -> o.category is 'package')[0]?.name
        pkg = pkg?.match(/（(.*)）/)?[1] or ''
        console.log pkg, company_doc.barcode, company_doc.profile.name, company_doc.profile.sex, company_doc.profile.age + "岁", company_doc.profile.notes?.join(' ')
      console.log ""
    process.exit()
