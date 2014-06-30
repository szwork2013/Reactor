moment = require "moment"
_      = require "underscore"

# 不太棒的是，遵循Mongoose的接口，档案未检索到时，无异常回调。
# departments需要populate么？
# route在必要时组装。其他都很棒。
module.exports = (record_schema) ->
  
  # options.paid_all 为 off 时，表示查询所有订单中科室的状态
  # options.paid_all 为 on时，表示只查询已付费或事后付费的科室状态
  record_schema.statics.barcode = (barcode, options, cb) ->
  #record_schema.statics.get_record_by_barcode = (barcode, options, cb) ->
    if 'function' is typeof options
      cb = options
      options = {}

    # ## 第一步：
    # # 
    # # 获取档案文档，取`samplings departments orders`键，得到`record`文档。
    @findOne(barcode: barcode)
    .populate('route')
    .exec (error, record) =>
      return cb error if error
      return cb() unless record
      record.pre_departments_status = {}
      for department in record.departments
        record.pre_departments_status[department.name] = department.status
      record.sync_departments options, (error) =>
        return cb error if error
        @model('Product').get_combos_by_orderids _.pluck(record.orders, '_id'), (error, combos) =>
          return cb error if error
          record.paper_report = if '纸质报告' in _.flatten(_.values(combos)) then on else off
          cb null, record
