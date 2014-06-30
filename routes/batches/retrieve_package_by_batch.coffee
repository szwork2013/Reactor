# 查找某批次下的套餐
#
# ## 获取套餐信息
#   + **资源地址**
#   + `/batches/:id/package?fields=category,name,configurations&enterprise=true`
#   + **例**
#     * 根据批次编号查找套餐信息
#     {
#       "_id": "5e5bb37258200ed9aabc8d01",
#       "order": 1,
#       "name": "大组合",
#       "category": "combo",
#       "configurations": [
#         {
#          "_id": "5e5bb37258200ed9aabc8d02",
#          "name": "小组合",
#          "sex": "男",
#          "age": {
#             "ut": 35,
#             "lt": 20
#           },
#          "price": 300,
#          "items": [
#             "6e5bb37258200ed9aabc8d02"
#          ]
#         }
#       ],
#       "batch": "4e5bb37258200ed9aabc5d11"
#     }
# ## 数据服务（应用于查找某批次下的套餐）
#   + 根据条件查询数据
#   + 查询成功返回套餐`pac`，失败发送错误信息。

app.get '/batches/:batch/package', authorize('nurse'), (req, res) ->
  {Product} = req.models
  {enterprise} = req.query
  {batch} = req.params
  Product.findOne({ batch: batch })
  .select(req.query.fields?.replace(/,/g, ' '))
  .exec (error, pac) ->
    return res.send 500, error.stack if error
    #if not enterprise
    #  Product.enterprise_ids (error, ids) ->
    #    return res.send 500, error.stack if error
    #    for c in pac.configurations
    #      if String(c._id) in ids.enterprise_combo
    #        # TODO: 这个逻辑有缺陷么?
    #        c.items = c.items.filter (i) -> String(i) not in ids.enterprise_item
    #    pac.configurations = pac.configurations.filter (c) -> c.items.length
    #    res.send pac
    #else
    res.send pac
