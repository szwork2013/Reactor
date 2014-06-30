jsdom  = require "jsdom"
crypto = require "crypto"

module.exports = (record_schema) ->
  record_schema.methods.update_guidance_card_hash = (cb) ->
    jsdom.env
      html: "http://#{@model('Record').host}:5124/records/#{@barcode}/guidance_card"
      done: (errors, window) =>
        return cb errors if errors
        doc = window.document
        str = ''
        for key, value of doc.querySelectorAll('.nochange')
          str += (value.innerHTML or '')
        shasum = crypto.createHash 'sha1'
        shasum.update str
        hash_id = shasum.digest('hex')
        @guidance_card_hash = hash_id
        cb()
