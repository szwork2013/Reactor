# Authored: 盛保善 @ 2014-04-12
_ = require 'underscore'

module.exports = (record_schema) ->
  record_schema.pre 'save', (callback) ->

    # 实际记账项为（由当前订单派生）：
    #
    # 1. 未到场客人无订单项记账；
    # 2. 已到场客人为全部记账项。
    next = if @status in ['未到场']
      []
    else
      @orders
      .filter(({paid}) -> paid in [2])
      .map((order) ->
        credit = order.toObject()
        credit.product_id = credit._id
        credit)

    # 先前记账项为（由记账记录派生）：
    #
    # 1. 按对应产品编号进行分组；
    # 2. 取每个产品编号组最末项；
    # 3. 选择类别为记账的记账项。
    prev = _(@credits)
    .chain()
    .groupBy('product_id')
    .map((credits) -> _(credits).last().toObject())
    .where(type: '记账')
    .value()

    # 记录待退账项（先前记账项中如今已不存在者）。
    next_index = _(next).indexBy('product_id')
    @credits.push prev
    .filter(({product_id}) -> not next_index[product_id])
    .map((credit) =>
      credit.type = '退账'
      credit)...

    # 记录待记账项（实际记账项中先前尚不存在者）。
    prev_index = _(prev).indexBy('product_id')
    @credits.push next
    .filter(({product_id}) -> not prev_index[product_id])
    .map((credit) =>
      credit.type = '记账'
      credit)...

    # 完成记退账工作。
    callback()
