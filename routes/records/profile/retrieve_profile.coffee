# 根据档案编号或者barcode查询客人基本信息
#
# ## 获取的客人基本信息
#   + **资源地址**
#   + `/records/:barcode/profile?fields={fields}`
#     * `barcode`：25条码编号
#   + **例**
#     * /records/00000004/profile
#   + **返回数据**
#     {
#       "_id": "7e5bb37258200ed9aabc8d04",
#       "profile": {
#         "name": "王六一",
#         "sex": "male",
#         "age": 30,
#         "source": "北京亿玛在线科技有限公司"
#        }
#      }
# ## 数据服务（应用于付费页面客人信息查询）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404

app.get '/records/:barcode/profile', authorize('cashier', 'admin'), (req, res) ->
  fields = req.query.fields?.split ','
  fields = if fields then fields.map (item) -> 'profile.' + item
  else ['profile']

  req.models.Record.findOne(barcode: req.params.barcode)
  .select(fields.join ' ')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    res.send record.profile
