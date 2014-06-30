mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  Record.find({'appeared.0': {'$gte': '2013-03-30', '$lte': '2013-08-24'}})
  .exec (error, records) ->
    return console.log error if error
    console.log records.length
    str = '到场日期,姓名,项目名称,单位名称\n'
    for record in records
      for department in record.departments
        if department.name is '放射科'
          for item in department.items
            if item.note isnt '放弃' and (item.conditions.length or item.normal or item.value?)
              str += record.appeared[0] + ',' + record.profile.name + ',' + item.name + ',' + record.profile.source + '\n'
    fs.writeFileSync('guests.csv', str, 'utf-8')
    process.exit()
