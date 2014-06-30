async = require 'async'
module.exports = (record_schema) ->

  record_schema.statics.import_multi_records_entries = (multiple_record_entries, department_name, doctor_name, callback) ->
    total_groups = multiple_record_entries.length
    total_items  = multiple_record_entries.reduce (memo, single_record_entries) ->
      memo + single_record_entries.entries.length
    , 0
    error_barcodes = []
    tasks = multiple_record_entries.map (single_record_entries) => (callback) =>
      @import_single_record_entries single_record_entries, department_name, doctor_name, (error, according_items) ->
        #return callback error if error
        error_barcodes.push error if error
        callback null, according_items
    async.parallelLimit tasks, 100, (error, valid_items) ->
      #return callback error if error
      callback (if error_barcodes.length then error_barcodes else null), total_items, (valid_items.reduce ((a, b) -> a + b), 0), total_groups
