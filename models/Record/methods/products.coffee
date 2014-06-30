_      = require "underscore"

# TODO: 改进模组引用的签名。
module.exports = (record_schema) ->
 
  record_schema.methods.products = () ->
    combos   = @orders.filter (order) -> order.category is 'combo' and order.paid isnt -1
    packages = @orders.filter (order) -> order.category is 'package' and order.paid isnt -1
    packages = _.sortBy packages, ((pkg) -> [3, 2, 0, 1].indexOf pkg.paid)
    combos.concat packages[0] or []
