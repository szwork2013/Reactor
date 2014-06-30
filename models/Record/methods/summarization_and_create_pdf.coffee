fairy  = require('fairy').connect()

module.exports = (record_schema) ->
  record_schema.statics.summarization_and_create_pdf = (barcode, callback) ->
    summarization = fairy.queue 'summarization'
    summarization.enqueue [@model('Record').host, barcode], (error, res) ->
      return callback error if error
      callback()
