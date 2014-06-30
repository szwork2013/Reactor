
# 对某科室的未完成项目和已延期项目进行放弃或延期
#
# ## 科室放弃或延期
#   + **资源地址**
#   + `/records/:barcode/departments/:department_id/status`
# ## 数据服务（应用于医生工作站、离场）
#   + 放弃或延期科室检查结果
#   + 放弃或延期成功后返回{}，失败发送错误信息。
mongoose = require "mongoose"

app.put '/records/:barcode/departments/:department_ids/status', authorize('mo', 'admin')
, (req, res) ->
  {Record} = req.models
  {barcode, department_ids} = req.params
  console.log barcode, department_ids
  do update_status = ->
    Record.barcode barcode, (error, record) ->
      console.log error if error
      return res.send 500, error.stack if error
      return res.send 404 unless record
      department_ids_array = department_ids.split(',')
      for department_id in department_ids_array
        record.departments.id(department_id)?.update_status(req.body.status)
      record.save (error) ->
        console.log error if error
        return update_status() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
