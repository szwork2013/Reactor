moment = require "moment"

module.exports = (record_schema) ->
  record_schema.statics.guest_login = (guest, cb) ->
    return cb() unless guest
    {name, hash_id} = guest
    @model('Record').findOne()
    .where('profile.name').equals(name)
    .where('profile.hash_id').equals(hash_id)
    .select('barcode customer_key customer_key1 customer_key2 profile pdf_created')
    .exec (error, record) =>
      return cb error if error
      return cb(null, []) unless record
      if record.profile.id?.length is 10
        year = record.profile.id.substring(0,4)
      else if record.profile.id?.length is 18
        year = record.profile.id.substr(6,4)
      else
        year = moment(record.profile.check_date).format('YYYY') - record.profile.age
      cond = {'$or':[]}
      if record.customer_key1
        cond['$or'].push customer_key1: record.customer_key1
      if record.customer_key2
        cond['$or'].push customer_key2: record.customer_key2
      console.log JSON.stringify cond
      return cb(null, [record]) unless cond['$or'].length
      # delete cond['$or'] unless cond['$or'].length
      @model('Record').find(cond)
      .select('barcode customer_key profile pdf_created')
      .exec (error, records) ->
        return cb error if error
        for record in records
          if record.profile.age isnt '#'
            record.span = (moment(record.profile.check_date).format('YYYY') - record.profile.age) - year
        records = records.filter (record) -> not record.span? or Math.abs(record.span) <= 1
        cb null, records
