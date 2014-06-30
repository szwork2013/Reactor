request = require 'superagent'
[barcode, oi] = process.argv[2..]
bua = 40
sos = + (+oi + 310 - 20) * 4
request.put("http://hswk.healskare.com:5124/records/#{barcode}/departments/bone_density/data")
  .set('Content-Type', 'application/json')
    .send({data: "#{sos}|#{bua}"})
      .end (err, res) ->
            console.log err, res.statusCode
