_      = require "underscore"

module.exports = (record_schema) ->
  record_schema.statics.get_substandard_items = (department) ->
    {cached_detail_expstr_hash} = @model('Department')
    {cached_A_level_conditions} = @model('SuggestionGroup')
    substandard = {}
    conditions_array = []
    items = []
    for item in department.items
      conditions_array.push(item.name + '正常') if item.normal
      for condition in item.conditions
      # 如果有detail，需要判定detail是否匹配该症状的表达式。
        if condition.detail?
          items.push item.name if condition.detail.match(new RegExp(cached_detail_expstr_hash[condition.name]))
        if condition.name in ['偏高', '偏低', '阳性', '阴性', '弱阳性']
          condition.name = item.name + condition.name
        condition.name = condition.summary or condition.name
        conditions_array.push condition.name
    found_level = _.find cached_A_level_conditions, (item) ->
      item.conditions.every((cond) -> cond in conditions_array)
    if found_level or items.length
      substandard.serious = if found_level then on else off
      substandard.items = items
    substandard
