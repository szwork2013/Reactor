# 取消采样
#
# ## 取消采样
#   + **资源地址**
#   + `/records/:barcode/samplings/:sampling_id`
# ## 数据服务（应用于采血护士站）
#   + 取消样本
#   + 取消成功返回{}，失败发送错误信息。
mongoose = require 'mongoose'

app.delete '/records/:barcode/samplings/:sampling_id', authorize('mo', 'admin'), (req, res) ->
  {barcode, sampling_id} = req.params
  {Record}               = req.models
  do undo_sampling = ->
    Record.barcode barcode, {paid_all: on}, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 404 unless record
      sampling = record.samplings.id sampling_id
      return res.send 404 unless sampling
      sampling.status = '未采样'
      sampling.sampled = undefined
      record.save (error) ->
        return undo_sampling() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
