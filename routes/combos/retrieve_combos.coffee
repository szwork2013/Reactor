# 对组合进行查询
#
# ## 获取组合信息
#   + **资源地址**
#   + `/combos?skip={skip}&limit={limit}&fields={fields}&filter={filter}`
#   + **例**
#     * 个人注册【获取新增组合项】
#       - /combos?fields=order,name,configurations
#     * 个人注册【获取常用组合项】
#       - /combos?fields=order,name,configurations&filter=popular
#
#   + **返回响应正文**
#     [{
#          "_id": "4e5bb37258200ed9aabc5d67",
#          "order": 1,
#          "name": "大组合",
#          "type": "combo",
#          "variations": [
#             {
#               .....
#             }  
#           ],
#       }, ...
#      ]

# ## 数据服务（应用于个人注册组合查询）
#   + 根据条件查询数据
#   + 查询成功返回数组`packages`，失败发送错误信息。

_  = require "underscore"

app.get '/combos', authorize('cashier'), (req, res) ->
  step1 = new Date
  {skip, limit, fields, filter, enterprise} = req.query
  query = req.models.Product.find()
  query.where('category').equals('combo')
  query.skip(skip) if skip
  query.limit(limit) if limit
  query.sort('order')
  query.select(fields?.replace(/,/g, ' '))
  query.exec (error, products) ->
    return res.send 500, error.stack if error
    return res.send products unless filter
    return res.send [] if filter isnt 'popular'
    if filter?.trim() is 'popular'
      for combo in products
        combo.configurations = combo.configurations.filter (item) -> item.popular
      products = products.filter (p)-> p.configurations.length
      res.send _.flatten _.pluck(products, 'configurations')
