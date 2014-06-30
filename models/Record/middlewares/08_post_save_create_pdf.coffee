fairy  = require('fairy').connect()

module.exports = (record_schema) ->
  record_schema.post 'save', (doc) ->
    # console.log 'post save enqueue summarization', doc.barcode, doc.summarize, doc.status
    if doc.status in ['已离场', '已完成', '已发电子报告', '已打印'] and not doc.summarize
      summarization = fairy.queue 'summarization'
      summarization.enqueue [@model('Record').host, doc.barcode], (error, res) ->
        console.log error if error
        doc.summarize = on
