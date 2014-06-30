moment   = require "moment"

module.exports = (record_schema) ->
  
  record_schema.methods.add_sampling = (sampling) ->
    @samplings.addToSet sampling
    @appeared.addToSet moment().format('YYYY-MM-DD')
