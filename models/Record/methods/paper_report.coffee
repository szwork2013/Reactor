moment = require "moment"
_      = require "underscore"

# 自动为之前客人更正出生日期与身份标识
module.exports = (record_schema) ->
  record_schema.statics.set_paper_report = (barcode, orderids, cb) ->
    @model('Product').get_combos_by_orderids orderids, (error, combos) =>
      return cb error if error
      paper_report = if '纸质报告' in _.flatten(_.values(combos)) then on else off
      @model('Record').update { barcode: barcode }, { paper_report: paper_report }, (error, numberAffected, raw) =>
        return cb error if error
        cb()
