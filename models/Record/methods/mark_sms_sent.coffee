module.exports = (record_schema) ->
  
  record_schema.statics.mark_sms_sent = (tel, cb) ->
    @model('Record').update { 'profile.tel': tel}, { '$inc': { sms_sent: 1 }}, { safe: true, multi: true }, cb
