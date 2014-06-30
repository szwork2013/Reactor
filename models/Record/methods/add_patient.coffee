module.exports = (record_schema) ->
  
  record_schema.methods.add_patient = (customer_key, cb) ->
    console.log 'add_patient.coffee'
    @model('Patient').findOne({customer_key: customer_key})
    .exec (error, patient) ->
      return cb error if error
      if patient
        tags = tags.filter((tag) -> tag not in patient.tags)
        patient.tags.push tag for tag in tags
