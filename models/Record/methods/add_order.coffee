module.exports = (record_schema) ->
  
  record_schema.methods.add_order = (order, cb) ->
    @orders.addToSet order
    @sync_departments cb
