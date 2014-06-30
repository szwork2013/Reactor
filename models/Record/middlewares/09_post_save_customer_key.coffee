moment = require "moment"

# 自动为之前客人更正出生日期与身份标识
module.exports = (record_schema) ->
  record_schema.post 'save', (doc) ->
    return unless doc.customer_key
    ids = doc.customer_key.split('|')
    if moment(ids[0]).isValid()
      customer_key = doc.profile.source + '|' + ids[1] + '|' + ids[2]
      @model('Record').update { customer_key: customer_key }, { customer_key: doc.customer_key }, { multi: true }, (error, numberAffected, raw) =>
        console.log error if error
