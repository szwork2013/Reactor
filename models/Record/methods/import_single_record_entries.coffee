{calibrate_precision, calc_threshold, calc_conditions, calc_value} = require "../../../utils/util.coffee"
moment = require 'moment'
_      = require 'underscore'
mongoose = require 'mongoose'

module.exports = (record_schema) ->

  record_schema.statics.import_single_record_entries = (single_record_entries, department_name, doctor_name, callback) ->
    {barcode, entries} = single_record_entries
    barcode = barcode.substr(0, barcode.length-2) if barcode.length is 10
    query = "barcode": barcode
    according_items = 0
    do add_item = =>
      @barcode barcode, (error, record) =>
        console.log '编号为' + barcode + '的客人出现异常：' + error.stack if error
        #return callback error if error
        return callback barcode, according_items if error or not record
        # 今后改进更详细的报错信息
        #return callback new Error "Record Not Found" unless record
        original_department = @model('Department').cached_departments_hash[department_name]
        # 今后改进更详细的报错信息
        #return callback new Error "Department Not Found" unless original_department
        department = record.departments.id original_department?._id
        console.log barcode unless department
        return callback barcode, according_items unless department
        # department_schema.methods.set_item = (item) ->
        # + 找到参考项目：A @parent().model('Department').cache[@name].cache_items[item.name.toUpper]
        # + 找到档案项目：B _.find(@items, (record_item) -> item.name.toUpperCase() in [r_i.name, r_i.abbr.toUpperCase()]
        # + 如果没有A或者B，返回0
        # + B.set_item(item, A)
        # 1. 将A的全部键值赋予B
        # 2. 根据Profile和A，更新B的ut、lt
        # 3. 将item的value和normal赋予B
        # 4. 计算B的conditions
        # + update_calculated_item()
        # department_schema.methods.update_calculated_item = ->
        #   
        # + 更新该科室下的计算项目的值与症状
        #   - 对该科室下所有计算项目A（从原始科室里面找）
        #   - 找到档案中对应项目B，如果没有的话，直接返回
        #   + B.set_item item, A
        #   1. 将A的全部键值赋予B
        #   2. 根据Profile和A，更新B的ut、lt
        #   3. 将item的value和normal赋予B
        #   4. 计算B的conditions
        
        error_barcode = ''
        # 遍历导入项目，添加到档案科室集合中。
        according_items = entries.reduce (memo, item) ->
          success = department.set_item item
          error_barcode = barcode if not success
          console.log record.barcode + '没有' + item.name if not success
          memo + success
        , 0

        finished =
          date_number: Date.now()
          date_string: moment().format('YYYY-MM-DD')
          # _id: ObjectId
          user_name: doctor_name

        department.checking = {}
        department.checking.finished = finished
        if department.name is '放射科'
          for item in department.items
            finished.user_name = if item.name is '胸部' then '郭学' else '纪树义'
            item.checking = {}
            item.checking.finished = finished
        record.appeared.addToSet moment().format('YYYY-MM-DD') unless record.appeared.length
        record.save (error, record) ->
          #return callback error if error
          console.log error_barcode = barcode, error if error
          return add_item() if error instanceof mongoose.Error.VersionError
          callback (if error_barcode then error_barcode else null), according_items
