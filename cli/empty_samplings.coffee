mongoose     = require 'mongoose'
models       = require "../models"
subdomain    = 'hswk.healskare.com'

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  Record.findOne(barcode: process.argv[2])
  .exec (error, record) ->
    return console.log error if error
    record.samplings = []
    record.save (error) ->
      console.log error if error
      process.exit()
