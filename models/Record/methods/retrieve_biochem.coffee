moment = require "moment"

module.exports = (record_schema) ->
  record_schema.statics.retrieve_biochemical = (code, barcode, plate_hole, callback) ->
    @barcode barcode, {paid_all: on}, (error, record) =>
      return callback error if error
      return callback new Error "Record not Found" unless record
      record.biochemical_items = []
      return callback null, record if code is '03'
      for department in record.departments
        continue unless department.name is '生化检验'
        department.touched = on
        for item in department.items
          console.log JSON.stringify item
          record.biochemical_items.push item.abbr.toUpperCase() unless item.status is '完成'
      if 'HBA1C' in record.biochemical_items
        record.biochemical_items.splice(record.biochemical_items.indexOf('HBA1C'), 1)
      if 'MALB' in record.biochemical_items
        record.biochemical_items.splice(record.biochemical_items.indexOf('MALB'), 1)
      record.biochemistry or = {}
      record.biochemistry.disk_and_position = plate_hole
      record.biochemistry.analyze_start =
        date_number: Date.now().valueOf()
        date_string: moment().format('YYYY-MM-DD')
      record.save()
      callback null, record
