module.exports = (record_schema) ->
  
  record_schema.statics.mark_sms_review_notice = (tel, cb) ->
    @model('Record').update { 'profile.tel': tel}, { '$set': { sms_review_notice: on }}, { safe: true, multi: true }, cb
