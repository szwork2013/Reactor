records = null

mongodb = require 'mongodb'
async = require 'async'
_ = require 'underscore'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  Department = client.collection 'departments'
  Department.find().toArray (error, departments) ->
    items = []
    for department in departments
      items = items.concat department.items.map (i) ->
        i.department = department.name
        i
    items = items.filter (i) -> items.some (j) -> j.name is i.name and i isnt j
    console.log items.map (i) -> i.department + '|' + i.name
    process.exit()
