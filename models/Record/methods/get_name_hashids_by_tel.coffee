_  = require "underscore"

module.exports = (record_schema) ->
  record_schema.statics.get_name_hashids_by_tel = (tel, cb) ->
    @find({'profile.tel': tel})
    .select('customer_key profile.name profile.hash_id profile.check_date')
    .exec (error, records) ->
      return cb error if error
      return cb null, [] unless records.length
      records = records.sort (a, b) ->
        if a.profile.check_date < b.profile.check_date then 1 else -1
      groups = _.groupBy records, (record) -> record.customer_key
      results = for customer_key, records of groups
        name: records[0].profile.name, hash_id: records[0].profile.hash_id
      cb null, results
