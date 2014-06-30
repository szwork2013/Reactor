_            = require 'underscore'
csv          = require 'csv'
mongoose     = require 'mongoose'
fs           = require 'fs'
models       = require "./models"
subdomain    = 'hswk.healskare.com'
moment       = require "moment"
fs           = require "fs"

models subdomain, (error, {Record}, settings) ->
  return console.error error if error
  company = process.argv[2] or ''
  Record.find({'appeared.0': {$gte: '2013-01-01'}})
  .select('profile orders')
  .exec (error, records) ->
    return console.log error if error
    records = records.filter (record) -> not record.profile.name.match(/(测试|王玲|刘正明|张俊民|盛保善)/) and not record.profile.source.match(/(个检|测试)/)
    records = records.map (record) -> record.toObject()
    records = records.sort (a, b) -> if a.profile.source > b.profile.source then 1 else -1
    datas = []
    for record in records
      for order in record.orders
        if order.category is 'package'
          console.log order.name.split('（')[0], '11111111111'
          console.log order.name.match(/（(.*)）/)?[1], '22222222222'
          big = order.name.split('（')[0]
          small = order.name.match(/（(.*)）/)?[1] or ''
          found_item = _.find datas, (data) -> data.big is big and data.small is small
          if found_item
            found_item.count += 1
          else
            datas.push big: big, small: small, count: 1
    console.log datas, 'datas'
    datas = datas.sort (a, b) -> if a.big > b.big then 1 else -1
    str = '大套餐,小套餐,人数\n'
    for data in datas
      str += data.big + ',' + data.small + ',' + data.count + '\n'
    fs.writeFileSync('tc.csv', str, 'utf-8')
    
