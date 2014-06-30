# 修改标本状态
#
# ## 修改标本状态
#   + **资源地址**
#   + `/records/:barcode/samplings/:sampling_id/status/:status?appeared=true`
#   + **例**
#     * 医生工作站和采血护士站
# ## 数据服务（应用于医生工作站和采血护士站）
#   + 修改样本状态
#   + 修改成功返回{}，失败发送错误信息。

mongoose = require 'mongoose'
moment   = require 'moment'

app.put '/records/:barcode/samplings/:sampling_id/status/:status', authorize('mo', 'admin'), (req, res) ->
  console.log "SAMPLING:ADD", req.params.barcode
  {barcode, sampling_id, status} = req.params
  {Record} = req.models
  do update_status = ->
    Record.barcode barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 404 unless record
      sampling = record.samplings.id sampling_id
      return res.send 404 unless sampling
      sampling.status = status
      if status is '已采样'
        sampling.sampled = req.event
        record.appeared.addToSet moment().format('YYYY-MM-DD') if req.query.appeared is 'true'
      else if status is '未采样'
        sampling.sampled = undefined
      record.save (error) ->
        return update_status() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
