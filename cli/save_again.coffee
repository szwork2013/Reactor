mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'
_            = require "underscore"

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  Record.barcode process.argv[2], (error, record) ->
    return console.log error if error
    console.log record.departments, 'departments'
    for department in record.departments
      if department.name is '放射科'
        found_item = _.find department.items, (item) -> item.name is '颈椎'
        department.items = department.items.remove found_item
        for item in department.items
          if item.name is '颈椎正侧位片'
            item.name = '颈椎'
            item._id  = '300000000000000000000001'
    #for image in record.images
    # if image.tag is '放射科:颈椎'
    #   image.tag = '放射科:胸部'
    record.save (error) ->
      console.log error if error
      process.exit()
