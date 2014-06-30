mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
_        = require "underscore"
redis    = require "node-redis"
redis_client = redis.createClient()
redis_client.subscribe "touch_suggestionsGroup"

#{conditions_to_string, string_to_conditions, calibrate_precision} = require "../util.coffee"
# TODO: 这个schema还有用么?
conditionSchema =
  name: String
  redirect: String
  repeatable: Boolean

conditionSchema = new Schema conditionSchema, {versionKey: off, id: off, _id: off}

suggestion_schema =
  #   0.  **症状名称**
  #   1.  **建议**
  #   2.  简写名称
  conditions: [String]
  # TODO: 保留name，删除redirect和summary
  summary:
    name: String
    redirect: String
  content : String
  combos: [String]
  importance : String

suggestion_schema = new Schema suggestion_schema # , {versionKey: off, id: off, _id: off}

#itemSchema.path('conditions_string').set (v) ->
  #@conditions = string_to_conditions v
  #v

suggestion_group_schema =

  # TODO: 直接利用mongoose默认行为。
  # 编号
  # _id : ObjectId
  # 建议组名称
  name : String
  order: {type: Number, index: true}
  # 症状
  suggestions: [suggestion_schema]
  # 症状字符串
  suggestions_string : String

module.exports = suggestion_group_schema = new Schema suggestion_group_schema # , {versionKey: off, id: off}

# TODO: 是不是没用了。
suggestion_group_schema.statics.get_suggestion_conditions = (cb) ->
  @find()
  .select('name suggestions.conditions')
  .exec (error, suggestionGroups) ->
    return cb error if error
    conditions = []
    for suggestionGroup in suggestionGroups
      for suggestion in suggestionGroup.suggestions
        for condition in suggestion.conditions
          conditions.push suggestionGroup.name + ' ' + condition.name
    cb null, _.uniq conditions

suggestion_group_schema.statics.cache = (cb) ->
  # return cb()
  redis_client.on "message", (channel, message) =>
    @set_suggestions_hash_cache() if channel is 'touch_suggestionsGroup'
  @set_suggestions_hash_cache(cb)

suggestion_group_schema.statics.set_suggestions_hash_cache = (cb) ->
  console.log "BEFORE FIND"
  @find()
  # TODO: 暂不控制MongoDB的IO。
  # .select('order suggestions')
  # .sort('order')
  .exec (error, suggestionGroups) =>
    console.log error
    return cb error if error
    suggestionGroups = suggestionGroups.map (s) -> s.toObject()
    # 级别症状
    level_conditions = []
    for suggestionGroup in suggestionGroups
      for suggestion in suggestionGroup.suggestions
        level_conditions.push
          level: suggestion.importance
          conditions: suggestion.conditions

    sa = suggestionGroups.reduce (memo, s) ->
      for suggestion in s.suggestions
        # TODO: 这似乎是一个map啊:)
        suggestion.conditions = suggestion.conditions.map((c) -> name: c.replace(/[?？]/, ''), repeatable: c?.match(/[?？]/)?) #c.match(/\?$/)?
        memo.push suggestion
      memo
    , []

    # 组装与某症状（名称）相关的全部建议。
    sh = sa.reduce (memo, suggestion) ->
      for condition in suggestion.conditions
        (memo[condition.name] or = []).push(suggestion) # unless memo[c.name]
      memo
    , {}
    # 预先存储未查项目需要匹配建议的情况。
    # TODO: 仍然挂在当前的`model`上面。
    # TODO: 把调整执行到位。
    @cached_unchecked_items = unchecked_items = _.uniq sa.reduce (memo, s) ->
      memo.concat (c.name.replace(/未查$/, '') for c in s.conditions when c.name.match /未查$/)
    , []
    @model('Department').cached_unchecked_items  = _.uniq unchecked_items
    @cached_suggestions_hash = sh
    @cached_A_level_conditions = level_conditions.filter((item) -> item.level is 'A')
    cb?()

# TODO: 针对最常见的建议，保证建议调整的正确性。
# TODO: 提供真实内容样例。
suggestion_group_schema.statics.tweak_content = (content, sex, age, conditions_hash) ->
  return content unless content.match /[\{]([^\{\}]+)[\}]/
  PATTERN_AGE_LT = /(\d+)\D*以上/
  PATTERN_AGE_UT = /(\d+)\D*以下/
  PATTERN_MALE   = /男/
  PATTERN_FEMALE = /女/
  PATTERN_NO_CONDITION = /^无(.+)/
  PATTERN = /[\{]([^\{\}]+)[\}]/g
  content_segments = []
  index = 0
  while match = PATTERN.exec(content)
    content_segments.push content.substring(index, match.index)
    index = PATTERN.lastIndex
    if (match_segments = match[1]?.split('|'))?.length is 2
      condition = match_segments[0]
      filter_sex = if condition.match(PATTERN_MALE) then '男' else if condition.match(PATTERN_FEMALE) then '女'
      filter_age_lt = +condition.match(PATTERN_AGE_LT)?[1]
      filter_age_ut = +condition.match(PATTERN_AGE_UT)?[1]
      if ((filter_age_lt or filter_age_ut or filter_sex) and \
      (not filter_age_lt or age >= filter_age_lt) and \
      (not filter_age_ut or age <  filter_age_ut) and \
      (not filter_sex or sex is filter_sex)) or \
      conditions_hash[condition] or \
      ((condition = condition.match(PATTERN_NO_CONDITION)?[1].trim()) and \
      not conditions_hash[condition])
        content_segments.push match_segments[1]
  content_segments.push content.substring index,content.length
  content_segments.join ''

# TODO: 建议模型中有虚拟键或者getter么?
suggestion_group_schema.set 'toJSON', {getters: on, virtuals: on}
