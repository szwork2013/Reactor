_ = require "underscore"

module.exports = (record_schema) ->
  # 如没有套餐为客人匹配套餐
  record_schema.statics.addOrder = (profile, product, orders) ->
    {age, sex} = profile
    order = _.find orders, (item) -> item.category is 'package'
    return orders if order
    configuration = _.find product?.configurations, (c) ->
      (c.age_lt <= age*1 or not c.age_lt or age is '#') and (c.age_ut >= age*1 or not c.age_ut? or age is '#') and (c.sex is sex or not c.sex?)
    return null unless configuration  #批次中没有符合客人的套餐
    # 如有匹配套餐则添加套餐
    orders.push
      _id: configuration._id
      name: product.name + '（'+ configuration.name + '）'
      category: 'package'
      paid: 2
      price: configuration.price
    orders
