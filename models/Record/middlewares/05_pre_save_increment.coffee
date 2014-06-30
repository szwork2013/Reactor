
module.exports = (record_schema) ->
  record_schema.pre 'save', (callback) ->
    @increment()
    callback()
