module.exports = (record_schema) ->
  
  record_schema.methods.delete_order = (order, cb) ->
    @orders.remove order
    @sync_departments paid_all: on, cb
