mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  Record.find({'appeared.0': '2013-10-16'})
  .exec (error, records) ->
    return console.log error if error
    console.log records.length
    str = '编号,项目,值\n'
    for record in records
      console.log record.barcode, 'barcode'
      for department in record.departments
        if department.name is '生化检验'
          for item in department.items
            if item.note isnt '放弃' and (item.conditions.length or item.normal or item.value?)
              if item.name is '高密度脂蛋白'
                value = (item.value * 0.85).toFixed(2)
                str += record.barcode + ',' + item.name + ',' + item.value + '\n'
    fs.writeFileSync('items.csv', str, 'utf-8')
    process.exit()
