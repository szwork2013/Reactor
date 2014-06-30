# 根据档案编号或者barcode查询未完成科室信息
#
# ## 获取的未完成科室信息
#   + **资源地址**
#   + `/records/:barcode/unfinished_departments`
#     * `barcode`：25条码编号
#   + **例**
#     * /records/00000004/unfinished_departments
#   + **返回数据**
#     [ 
#       {
#         "_id":     "7e5bb37258200ed9aabc8d04",
#         "name":    "内科",
#         "status":  "未完成"
#       },
#       {
#         "_id":    "7e5bb37258200ed9aabc8d03",
#         "name":   "血压",
#         "status": "延期"
#       },
#       {
#         "_id":    "7e5bb37258200ed9aabc8d04",
#         "name":   "外科",
#         "status": "放弃"
#       }
#     ]
# ## 数据服务（应用于离场未完成科室查询）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404

app.get '/records/:barcode/unfinished_departments', authorize('cashier', 'admin'), (req, res) ->
  {Record} = req.models
  Record.barcode req.params.barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    res.send record.unfinished_departments
