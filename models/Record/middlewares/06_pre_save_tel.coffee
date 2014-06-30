
module.exports = (record_schema) ->
  record_schema.pre 'save', (callback) ->
    @tel_modified = @isModified('profile.tel')
    callback()
