# 根据档案编号或者barcode查询档案
#
# ## 获取的个人档案信息
#   + **资源地址**
#   + `/records/:barcode/samplings?match=采血`
#     * `id`：档案编号或者25条码编号
#   + **例**
#     * /records/00000004/samplings?match=采血
#   + **返回数据**
#     [
#         {
#           "name": "紫色采血管（1）",
#           "tag": "血常规+糖",
#           "departments": [
#             "生化检验",
#             "血常规"
#           ],
#           "_id": "0000000403",
#           "color": "#912CEE"
#         }
#     ]
# ## 数据服务（应用于抽血护士站查询）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404
_  = require "underscore"

app.get '/records/:barcode/samplings', authorize('nurse'), (req, res) ->
  {Record} = req.models
  Record.barcode req.params.barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    record.samplings = record.samplings.filter((s) -> s.name?.match new RegExp(req.query.match)) if req.query.match
    #res.send record.samplings.sort((a, b) -> if a.color > b.color then 1 else -1)
    res.send record.samplings.sort((a, b) -> if a._id > b._id then 1 else -1)
