# 对套餐进行查询
#
# ## 获取的套餐信息
#   + **资源地址**
#   + `/packages?skip={skip}&limit={limit}&fields={fields}`
#   + **例**
#     * 个人注册【获取个人套餐】
#       - /packages?fields=name,configurations
#     * 个人注册【获取团体套餐】
#       - /packages
#
#   + **返回响应正文**
#     [{
#          "_id": "4e5bb37258200ed9aabc5d67",
#          "order": 1,
#          "name": "大套餐",
#          "type": "individual",
#          "variations": [
#             {
#              ......
#             }  
#           ],
#       }, ...
#      ]

# ## 数据服务（应用于个人注册套餐查询）
#   + 根据条件查询数据
#   + 查询成功返回数组`packages`，失败发送错误信息。

app.get '/packages', authorize('nurse'), (req, res) ->
  query = req.models.Product.find()
  query.where('category').equals('package')
  query.exists('batch', false)
  query.skip(req.query.skip) if req.query.skip
  query.limit(req.query.limit) if req.query.limit
  query.sort('order')
  query.select(req.query.fields?.replace(/,/g, ' '))
  query.exec (error, products) ->
    return res.send 500, error.stack if error
    res.send products
