module.exports = (record_schema) ->
  
  record_schema.methods.add_payment = (payment, cb) ->
    @payments.addToSet payment
    @sync_departments cb
