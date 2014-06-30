# 保存采样标本结果
#
# ## 保存采样标本
#   + **资源地址**
#   + `/records/:barcode/samplings?appeared=true`
#   + **例**
#     * 医生工作站和采血护士站
#     * `req.body`内容分别如下：
#     * 临床采样
#      {
#        _id: '1000012201'
#      }
# ## 数据服务（应用于医生工作站和采血护士站）
#   + 新增样本信息
#   + 新增成功返回{}，失败发送错误信息。
mongoose = require 'mongoose'
moment   = require 'moment'

reception = new RegExp (['尿', '便', '基因', '乙肝', 'HBV', '早餐']).join('|')
app.post '/records/:barcode/samplings', authorize('mo', 'admin'), (req, res) ->
  return res.send {} unless req.body._id
  {Record} = req.models
  barcode = req.params.barcode
  do add_sampling = ->
    Record.barcode req.params.barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 404 unless record
      record.event = req.event
      sampling = record.samplings.id req.body._id
      return res.send 404 unless sampling
      return res.send {} if sampling.status in ['已采样', '已删除']
      sampling.status = '已采样'
      sampling.sampled = req.event

      # 样本采样接口：
      #
      # 推入一站检查信息，行为文字为：
      #
      #   + 名称含/采血/的：采血（生化），推站时不合并名称，以便了解采血数量；
      #   + 前台负责发放的：领取尿杯，推站时不合并名称，简化工程；
      #   + 名称为心电图的：心电图；
      #   + 其余为：宫颈刮片（采样）。
      #
      # TODO: 样本取消采样之后，尚未做处理。
      action = if /采血/.test(sampling.name)
        "采血（#{sampling.lines[2]}）"
      else if reception.test(sampling.name)
        "领取#{sampling.name}"
      else if sampling.name is '心电图'
        '心电图'
      else
        "#{sampling.name}（采样）"
      now = Date.now()
      record.add_stop
        user_id   : req.user?._id
        user_name : req.user?.name
        start     : req.session.stops[barcode] ?= now
        action    : action
        end       : now
        date      : moment(now).format('YYYY-MM-DD')

      # 样本。
      record.appeared.addToSet moment().format('YYYY-MM-DD') if req.query.appeared is 'true'
      record.save (error) ->
        return add_sampling() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
