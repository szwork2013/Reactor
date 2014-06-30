async = require 'async'
module.exports = (record_schema) ->

  record_schema.statics.import_multi_tct = (multiple_record_entries, department_name, doctor_name, callback) ->
    total_groups = multiple_record_entries.length
    total_items  = multiple_record_entries.reduce (memo, single_record_entries) ->
      memo + single_record_entries.entries.length
    , 0
    tasks = multiple_record_entries.map (single_record_entries) => (callback) =>
      @import_tct single_record_entries, department_name, doctor_name, (error, according_items) ->
        return callback error if error
        callback null, according_items
    async.parallel tasks, (error, valid_items) ->
      return callback error if error
      callback null, total_items, (valid_items.reduce ((a, b) -> a + b), 0), total_groups
