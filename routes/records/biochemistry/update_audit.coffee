# 标识生化审核状态
#
# ## 
#   + **资源地址**
#   + `/records/:id/biochemistry/audit`
#   + **例**
#     *  /records/506036b8fdeedc3e31000006/biochemistry/audit
# ## 数据服务（应用于标记生化检验科室已审核）
#   + 根据档案编号查询档案
#   + 添加修改项成功后返回{}，失败发送错误信息。
_  = require "underscore"

app.post '/records/:barcode/biochemistry/audit', authorize('admin', 'doctor'), (req, res) ->
  req.models.Record.barcode req.params.barcode, {paid_all: on}, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    department = _.find record.departments, (department) -> department.name is '生化检验'
    return res.send 400 if department.status isnt '待审核'
    record.biochemistry.audit = req.event
    record.save (error) ->
      return res.send 500, error.stack if error
      res.send {}
