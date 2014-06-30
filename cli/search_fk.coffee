models = require '../models'
_      = require 'underscore'

models 'test.healskare.com', (error, models, settings) ->
  {Record} = models
  Record.find({'appeared': {'$ne': []}, 'departments.name': '妇科', 'profile.batch': '521aea17c14a03637e000005'})
  .select('departments')
  .exec (error, records) ->
    return console.log error.stack if error
    console.log records.length, 'count'
    fk = {}
    for record in records
      for department in record.departments
        if department.status is '已完成' and department.name is '妇科'
          fk[department.name] or = 0
          fk[department.name] += 1
    console.log fk, 'fk'
    process.exit()
