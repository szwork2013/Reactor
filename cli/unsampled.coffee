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
    for id in ['1001565402', '1001565401', '1001565403']
      xcg = record.samplings.id id
      xcg.status = '未采样'
      xcg.sample = undefined
    record.save (error) ->
      console.log error if error
      process.exit()
