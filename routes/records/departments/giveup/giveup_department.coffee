
# 对某科室的未完成项目和已延期项目进行放弃
#
# ## 科室放弃
#   + **资源地址**
#   + `/records/:barcode/departments/:department_id/giveup`
# ## 数据服务（应用于医生工作站、离场）
#   + 放弃科室检查结果
#   + 放弃成功后返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.post '/records/:barcode/departments/:department_id/giveup', authorize('mo', 'admin')
, ({params: {barcode, department_id}, models: {Record}, host: host}, res) ->
  do giveup_department = ->
    Record.giveup_or_reschedule_departments barcode, department_id, '放弃', (error, record) ->
      return giveup_department() if error instanceof mongoose.Error.VersionError
      return res.send 500, error.stack if error
      return res.send 404 unless record
      res.send {}
