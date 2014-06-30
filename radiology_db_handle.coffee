redis  = require 'node-redis'
_      = require 'underscore'
async  = require "async"
client = redis.createClient()

client.smembers "HSWK.HEALSKARE.COM:放射学:胸部:未诊断", (err, barcodes1) =>
  barcodes1 = (barcodes1 + '').split(',').filter((code) -> code)
  console.log barcodes1, '胸部:未诊断'
  client.keys "HSWK.HEALSKARE.COM:放射学:胸部:诊断中:*", (err, barcodes2) ->
    barcodes2 = (barcodes2 + '').split(',').filter((code) -> code)
    console.log barcodes2, '胸部:诊断中'
    client.smembers "HSWK.HEALSKARE.COM:放射学:颈椎:未诊断", (err, barcodes3) =>
      barcodes3 = (barcodes3 + '').split(',').filter((code) -> code)
      console.log barcodes3, '颈椎:未诊断'
      client.keys "HSWK.HEALSKARE.COM:放射学:颈椎:诊断中:*", (err, barcodes4) ->
        barcodes4 = (barcodes4 + '').split(',').filter((code) -> code)
        console.log barcodes4, '颈椎:诊断中'
        client.smembers "HSWK.HEALSKARE.COM:放射学:腰椎:未诊断", (err, barcodes5) =>
          barcodes5 = (barcodes5 + '').split(',').filter((code) -> code)
          console.log barcodes5, '腰椎:未诊断'
          client.keys "HSWK.HEALSKARE.COM:放射学:腰椎:诊断中:*", (err, barcodes6) ->
            barcodes6 = (barcodes6 + '').split(',').filter((code) -> code)
            console.log barcodes6, '腰椎:诊断中'
