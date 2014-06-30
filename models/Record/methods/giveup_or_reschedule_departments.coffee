moment = require "moment"
_      = require "underscore"

# 不太棒的是，遵循Mongoose的接口，档案未检索到时，无异常回调。
# departments需要populate么？
# route在必要时组装。其他都很棒。
module.exports = (record_schema) ->
  
  record_schema.statics.giveup_or_reschedule_departments = (barcode, department_ids, destination_status, cb) ->
    department_ids = department_ids.split ','
    @barcode barcode, (error, record) ->
      return callback error if error
      return callback unless record
      for department in department_ids.map((id) -> record.departments.id id).filter((x) -> x)
        for item in department.items
          item.status = destination_status unless item.value or item.normal or item.conditions?.length
        console.log JSON.stringify department, 'department'
      record.save cb
