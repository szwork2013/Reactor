
# 对某科室的未完成项目和已放弃项目进行延期
#
# ## 科室延期
#   + **资源地址**
#   + `/records/:barcode/departments/:department_id/reschedule`
# ## 数据服务（应用于医生工作站、离场）
#   + 延期科室检查结果
#   + 延期成功返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.post '/records/:barcode/departments/:department_id/reschedule', authorize('mo', 'admin')
, ({params: {barcode, department_id}, models: {Record}, host: host}, res) ->
  do reschedule_department = ->
    Record.giveup_or_reschedule_departments barcode, department_id, '延期', (error, record) ->
      return reschedule_department() if error instanceof mongoose.Error.VersionError
      return res.send 500, error.stack if error
      return res.send 404 unless record
      res.send {}
