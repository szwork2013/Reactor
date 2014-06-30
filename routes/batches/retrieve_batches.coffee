# 对批次进行查询
#
# ## 获取批次信息
#   + **资源地址**
#   + `/batches?q={q}&fields={fields}&skip={skip}`
#   + **例**
#     * /batches?q=北京&fields=company&limit=20
#     * /batches?status=proposal&fields=company,registration.staff.name
#     * 根据单位检索单位、预约时间
#     批次名称、批次编号、套餐编号【散客注册中模糊查询单位名称】
#    [
#      {
#        _id: '001',
#        company: "北京亿玛在线科技有限公司",
#        reservation_range: "2001-01-01至2001-01-31"
#      }
#    ]
# ## 数据服务（应用于散客注册中模糊查询单位名称）
#   + 根据条件查询数据
#   + 查询成功返回数组`batches`，失败发送错误信息。

{XRegExp} = require 'xregexp'
mongoose  = require 'mongoose'
ObjectId  = mongoose.Types.ObjectId

app.get '/batches', authorize('cashier'), (req, res) ->
  {q, status, my} = req.query
  {Batch, Record} = req.models
  query = Batch.find()
  query.where("company").regex(XRegExp.escape q) if q
  query.where("status").in(['proposal', 'ongoing']) unless status
  query.where("status").in(status.split(',')) if status
  if my is 'true'
    query.where("registration.user_id").equals(new ObjectId req.user?._id) if 'admin' not in (req.user?.roles or [])
  query.skip(req.query.skip) if req.query.skip
  query.limit(req.query.limit) if req.query.limit
  query.sort('-registration.date_number')
  .select(req.query.fields?.replace(/,/g, ' '))
  .exec (err, batches) ->
    return res.send 500, err.stack if err
    return res.send batches unless batches.length
    if req.query.q?
      count = batches.length
      for batch in batches
        batch.populate_reservation_range (err, data) ->
          return res.send 500, err.stack if err
          res.send (batches.map (b) -> b.toObject()) unless --count
    else if status
      return res.send batches if status is 'proposal'
      ids = batches?.map (batch) -> batch._id
      commands = []
      commands.push
        '$match':
          'profile.batch':
            '$in': ids
      commands.push
        '$project':
          '_id': 1
          'batch': '$profile.batch'
          'appeared': $cond: [{$eq:['$appeared', []]},0,1]
          'report_complete_date': $cond: ['$report_complete_date',1,0]
          'printed_date':  $cond: ['$printed_date',1,0]
      commands.push
        '$group':
          '_id': '$batch'
          'registered':
            '$sum': 1
          'appeared':
            '$sum': '$appeared'
          'report_complete_date':
            '$sum': '$report_complete_date'
          'printed_date':
            '$sum': '$printed_date'
      Record.aggregate commands, (error, results) ->
        return res.send 500, error.stack if error
        result = results?.reduce (memo, item) ->
          memo[item._id] = item
          memo
        , {}
        batches = batches.map (batch) -> batch.toJSON()
        for batch in batches
          batch.registered = result[batch._id]?.registered or 0
          batch.appeared   = result[batch._id]?.appeared or 0
          batch.report_complete_date = result[batch._id]?.report_complete_date or 0
          batch.printed_date = result[batch._id]?.printed_date or 0
        res.send batches
    else
      res.send batches
