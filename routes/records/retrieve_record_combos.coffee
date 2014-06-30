# 根据档案编号或者barcode查询档案
#
# ## 获取客人订单中涵盖的大组合、小组合
#   + **资源地址**
#   + `/records/:id/combos`
#     * `id`：档案编号或者25条码编号
#   + **例**
#     * /records/00000004/combos
# ## 数据服务（应用于抽血站ipad组合查询）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404
ObjectId = require("mongoose").Types.ObjectId

app.get '/records/:barcode/combos', authorize('nurse'), (req, res) ->
  {Record, Product} = req.models
  {category} = req.query
  Record.barcode req.params.barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    record.departments = record.departments.filter (d) -> d.status isnt '未付费' and d.required_samplings[0]?.match /采血/
    items = record.departments.reduce (memo, d) ->
      for item in d.items
        memo.push item._id
      memo
    , []
    paid_package_ids = record.orders?.reduce (memo, order) ->
      memo.push order._id if order.paid and order.category is 'package'
      memo
    , []
    paid_combo_ids = record.orders?.reduce (memo, order) ->
      memo.push String(order._id) if order.paid and order.category is 'combo'
      memo
    , []
    delete record.orders
    commands = []
    commands.push $match:
      'category': 'combo'
    commands.push $unwind: '$configurations'
    commands.push $project:
      _id:1
      name:1
      'configurations._id':'$configurations._id'
      'configurations.name': '$configurations.name'
      'configurations.items': '$configurations.items'
    commands.push $unwind: '$configurations.items'
    commands.push $match:
      'configurations.items':
        '$in': items
    commands.push $group:
      _id: "$configurations.name"
      name:
        '$last':'$name'
      'configurations_id':
        '$last':'$configurations._id'
      'configurations_name':
        '$last':'$configurations.name'
    commands.push $group:
      _id: "$name"
      name:
        '$last':'$name'
      configurations:
        '$push':
          '_id':'$configurations_id'
          'name':'$configurations_name'
    Product.aggregate commands, (error, results) ->
      return res.send 500, error.stack if error
      console.log results, 'results'
      commands = []
      commands.push $unwind: '$configurations'
      commands.push $match:
        'configurations._id':
          '$in': paid_package_ids or []
      commands.push $project:
        "_id": 1
        'name':1
        "configurations._id":1
        "configurations.combos": 1
      commands.push $unwind:
        '$configurations.combos'
      commands.push $project:
        'combos': '$configurations.combos'
      Product.aggregate commands, (error, products) ->
        return res.send 500, error.stack if error
        console.log products, 'products'
        combos = products?.reduce (memo, product) ->
          memo.push String(product.combos)
          memo
        , []
        combos_ids = combos.concat paid_combo_ids
        for result in results
          result.configurations = result.configurations.filter (c) ->
            String(c._id) in combos_ids
        res.send results.filter (r) -> r.configurations.length
