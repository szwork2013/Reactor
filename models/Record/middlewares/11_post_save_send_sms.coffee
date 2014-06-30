
module.exports = (record_schema) ->
  record_schema.post 'save', (doc) ->
    if doc.profile.tel
      if (doc.tel_modified and doc.appeared.length) \
      or (doc.profile.tel and doc.appeared.length and not doc.sms_sent)
        @model('Record').send_sms doc.profile.tel, doc.profile, (error) ->
          console.log error if error
