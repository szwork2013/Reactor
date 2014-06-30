_      = require "underscore"
redis  = require "node-redis"
redis_client = redis.createClient()

publish = (topic, send_data) ->
  redis_client.publish topic, JSON.stringify send_data

module.exports = (record_schema) ->
  record_schema.post 'save', (doc) ->
    host = @model('Record').host.toUpperCase()
    if '外检' not in doc.profile.notes and doc.biochemistry_status isnt '未付费'
      {barcode, profile, departments, biochemistry, samplings} = doc
      bio_sampling     = _.find samplings, (sampling) -> sampling.tag is '生化'
      found_department = _.find departments, (d) -> d.name is '生化检验'
      if found_department
        data =
          barcode: barcode
          profile:
            name: profile.name
            sex: profile.sex
            age: profile.age
          plate_hole: biochemistry?.disk_and_position or ''
          sample_date: bio_sampling?.sampled?.date_string or ''
          approval_date: biochemistry?.audit?.date_string or ''
          items: found_department.items
          status: found_department.status
        publish "#{host}:NEW_BIOCHEMISTRY_STATUS_CHANGE", data
