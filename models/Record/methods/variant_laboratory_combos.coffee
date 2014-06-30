_ = require "underscore"

module.exports = (record_schema) ->
  
  # 将实验室项目和实验室组合合并在一起
  record_schema.methods.varianted_laboratory_combos = (laboratory_items, laboratory_combos) ->
    return [] unless laboratory_items.length
    laboratory_items = laboratory_items.reduce (memo, item) ->
      memo[item._id] = item
      memo
    , {}
    lab_items = []
    for combo in laboratory_combos
      first_combo = on
      for config in combo.configurations
        config.name = config.name.replace /（企业版）/, ''
        first_item = on
        for item in config.items
          if laboratory_items[item._id]
            _.extend item, laboratory_items[item._id]
            item.big_combo = combo.name if first_combo and first_item
            if first_item
              item.small_combo = config.name
              first_item = first_combo = off
            lab_items.push item
      delete combo.configurations
    lab_items
