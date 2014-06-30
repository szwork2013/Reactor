{calibrate_precision, calc_threshold, calc_conditions, calc_value} = require "../../../utils/util.coffee"
moment = require 'moment'
_      = require 'underscore'

module.exports = (record_schema) ->

  record_schema.statics.import_tct = (single_record_entries, department_name, doctor_name, callback) ->
    {barcode, entries} = single_record_entries
    query = "barcode": barcode
    @barcode barcode, (error, record) =>
      return callback error if error
      according_items = 0
      return callback null, according_items unless record
      original_department = @model('Department').cached_departments_hash[department_name]
      {_id, name, category} = original_department
      now = moment().format('YYYY-MM-DD')
      department = record.departments.id _id
      return callback null, according_items unless department

      # 组装item所有键后，如果科室中存在此项目
      # 删除科室中的项目并用组装好的项目填充
      # 如果科室中不存在项目，直接添加项目。
      addToSet_item = (item, target_item) ->
        _.extend target_item, item
      # 遍历导入项目，添加到档案科室集合中
      for item in entries
        item.name = item.name.toUpperCase()
        target_item = _.find department.items, (i) ->
          i.name.toUpperCase() is item.name or i.abbr?.toUpperCase() is item.name
        continue unless target_item # 拒绝订单中没有的项目
        addToSet_item item, target_item
        according_items++
     
      department.checking |= {}
      department.checking.finished =
        date_number: Date.now()
        date_string: moment().format('YYYY-MM-DD')
        name: doctor_name
      record.save (error, record) ->
        return callback error if error
        callback null, according_items
