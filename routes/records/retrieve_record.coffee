# 根据档案编号或者barcode查询档案
#
# ## 获取的个人档案信息
#   + **资源地址**
#   + `/records/:barcode?fields={fields}&departments={roomid}`
#     * `id`：档案编号或者25条码编号
#   + **例**
#     * /records/00000003?fields=profile,orders,payments
#     * /records/00000004?fields=profile,orders
#     * /records/00000004?fields=profile,departments&departments=500000000000000000000000,110000000000000000000000,010000000000000000000000
#     * /records/00000004?fields=profile,departments&departments=骨密度&age_limit=true
# ## 数据服务（应用于档案查询）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404

app.get '/records/:barcode', authorize('nurse'), (req, res) ->
  {Record, Department} = req.models
  {fields, age_limit, departments} = req.query
  {barcode} = req.params
  Record.barcode req.params.barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    return res.send 404 if record.profile.age > 83 and age_limit # TODO: WTF?
    {cached_departments_hash} = Department
    if departments
      require_rooms = (departments.split ',') or []
      ids = require_rooms.map((name) -> cached_departments_hash?[name]?._id?.toString() or name)
      record.departments = record.departments.filter (d) -> d._id.toString() in ids
    record.orders = record.orders.filter((order) -> order.paid isnt -1)

    # 医生调档之后，将客人调档时间持久化至`session`中。
    unless req.session.barcode is barcode
      req.session.barcode = barcode
      req.session.stops[barcode] = Date.now()

    res.send record
