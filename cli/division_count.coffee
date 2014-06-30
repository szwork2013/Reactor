fs = require 'fs'
_  = require 'underscore'
mongodb = require 'mongodb'
async = require 'async'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.find({'profile.source': '开关厂'}).toArray  (err, docs) ->
    console.log docs.length
    result = {}
    for record in docs
      continue if record.profile.name.match /测试/
      result[record.profile.division?.trim() or '其他部门'] or = 0
      result[record.profile.division?.trim() or '其他部门']++

    for division, count of result
      console.log division, count
