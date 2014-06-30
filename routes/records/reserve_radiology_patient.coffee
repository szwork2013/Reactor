redis  = require 'node-redis'
_      = require 'underscore'
async  = require "async"
client = redis.createClient()

app.post '/reserve_radiology_patient', (req, res) ->
  {barcode, part, items} = req.body
  patients = []
  host  = req.host.toUpperCase()
  tasks = (items or []).map (item_name) ->
    (callback) ->
      client.smembers "#{host}:放射学:#{item_name}:未诊断", (err, barcodes1) =>
        barcodes1 = (barcodes1 + '').split(',').filter((code) -> code)
        client.keys "#{host}:放射学:#{item_name}:诊断中:*", (err, barcodes2) ->
          barcodes2 = (barcodes2 + '').split(',')
          barcodes2 = barcodes2.map (barcode) ->
            arr_barcodes = barcode.split(':')
            arr_barcodes[arr_barcodes.length - 1]
          barcodes2 = barcodes2.filter((code) -> code)
          console.log barcodes1, barcodes2, '11111111111'
          barcodes1 = _.difference(barcodes1, barcodes2)
          for barcode1 in barcodes1
            patients.push barcode: barcode1, part: item_name
          callback()
  
  async.parallel tasks, (error) ->
    return res.send 500, error if error
    patients.unshift barcode: barcode, part: part if barcode
    send_data = {}
    send_patients = []
    index = 0
    for patient in patients
      if index < 2
        send_patients.push patient
        client.set "#{host}:放射学:#{patient.part}:诊断中:#{patient.barcode}", patient.barcode
        client.expire "#{host}:放射学:#{patient.part}:诊断中:#{patient.barcode}", 1*60
      index++
    if send_patients.length
      send_data['start'] = send_patients[0] unless req.body.barcode
      send_data['next']  = send_patients[1] if send_patients[1]
    console.log send_data, 'send_data'
    res.send send_data
