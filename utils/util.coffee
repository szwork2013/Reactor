_      = require 'underscore'
coffee = require 'coffee-script'
fs     = require 'fs'
moment = require 'moment'

# TODO: 是否亦需要?
# ## 获取当前目录下的所有文件物理路径
exports.walk = walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    if err
      return done err
    pending = list.length
    if not pending
      return done null, results
    for file in list
      do (file) ->
        file = dir + '/' + file
        fs.stat file, (err, stat) ->
          if stat and stat.isDirectory()
            walk file, (err, res) ->
              results = results.concat res
              if not --pending
                done null, results
          else
            results.push file
            if not --pending
              done null, results

# TODO: 使用D3进行日期格式化，或者使用moment进行日期格式化。
# ## 日期格式转化
exports.format = (date) ->
  moment(date).format 'YYYY-MM-DD'

# TODO: RENAME string2date
# ## 将字符串`2010-04-03`转化为`Tue Apr 03 2012 00:00:00 GMT+0800 (CST)`
exports.stringtodate = (str) ->
  moment(str, ["YYYY-MM-DD"]).toDate()

exports.no_cache = (req, res, next) ->
  res.setHeader "Cache-Control", "no-cache"
  next()

calc_lt_ut = (expression, basic) ->
  expression = coffee.compile expression.toString(), {bare:1}
  try
    eval "with(basic){#{expression}}"
  catch e
    null

# 同时处理下限、上限、上下限有效数字、结果有效数字。
# 以Mocha测试加固。
exports.calc_threshold = (item, basic) ->
  # 用于计算上下限
  if isNaN(item.ut*1) and item.ut
    item.ut = calc_lt_ut item.ut, basic
  if isNaN(item.lt*1) and item.lt
    item.lt = calc_lt_ut item.lt, basic
  [lt, ut] = calibrate_precision(item.lt?.toString(), item.ut?.toString())
  item.lt = lt
  item.ut = ut
  precision  = (item.lt?.split('.')[1]?.length or item.ut?.split('.')[1]?.length) or 0
  if item.value?
    if not isNaN(item.value.trim()*1)
      item.value = parseFloat(item.value.trim()).toFixed(precision)
    else
      item.value = item.value.trim()

exports.calc_value = (expression, department) ->
  values = {}
  department.items.forEach (item) ->
     values[item.name] = parseFloat(item.value) if item.category is 'number'
  expression = coffee.compile expression.toString(), {bare: 1}
  try
    value = eval "with(values){#{expression}}"
    if isNaN value then '——' else value?.toFixed(2)?.toString()
  catch e
    '——'

exports.calc_conditions = (item, basic) ->
  conditions = []
  if item.value
    value = item.value.toString()
    # TODO: 检验科中大部分项目不再写偏高、偏低字样了。如果偏高或偏低，既向症状中
    # 推入［项目名称＋（偏高｜偏低）］
    # 第一步，如果存在上下限，并且输入的是数字或者是浮点数
    if item.ut isnt undefined and parseFloat value * 1 # 上下限分别判断
      if parseFloat(value) > parseFloat item.ut
        condition = _.find item.conditions, (condition) -> condition.name is '偏高'
        conditions.push condition if condition
    
    if item.lt isnt undefined and parseFloat value * 1
      if parseFloat(value) < parseFloat item.lt
        condition = _.find item.conditions, (condition) -> condition.name is '偏低'
        conditions.push condition if condition
    
    # 第二步，通过输入值，找conditions
    # console.log "Step 2", value, JSON.stringify item.conditions
    condition = _.find item.conditions, (condition) -> condition.name is value
    conditions.push condition if condition
    # console.log conditions
    # 第三步，走表达式
    value = value.match /\d+(\.\d+)?/g
    context = {}
    if value
      context.value = value[0]
      _.each value, (x, index) -> context['value' + (index + 1)] = eval value[index]
    else
      context = {value: item.value}
    context = _.extend context, basic
    condition = _.find item.conditions, (condition) ->
      if condition.expression
        # console.log condition.expression
        expression = condition.expression.replace(/第一个值/g,' value1 ')
          .replace(/第二个值/g,' value2 ').replace(/值/g,' value ')
          .replace(/性别/g,' sex ').replace(/男/g,' 男 ')
          .replace(/女/g,' 女 ').replace(/大于/g, ' > ')
          .replace(/小于/g, ' < ').replace(/等于/g,' is ')
          .replace(/并且/g, ' and ')
          .replace(/或者/g, ' or ')
        try
          expression = coffee.compile expression, {bare:1}
          # console.log "with(context){#{expression}}"
          eval "with(context){#{expression}}"
        catch e
          false
    conditions.push(condition) if condition
    # console.log "B", conditions
  if conditions.length > 1
    conditions = [conditions[conditions.length-1]]
  conditions

# TODO: 两个工作，置于两个中间件当中。
exports.authorize = () ->
  requiredRoles = arguments
  (req, res, next) ->
    next()
      #return res.send 401 unless req.user
      #grantedRoles = if req.user then req.user.roles else req.user
      #requiredRoles = _.values(requiredRoles)
      #  .map (item) -> item.replace /(room_id)/, "#{req.params.id}"
      #if grantedRoles and _.intersection(requiredRoles, grantedRoles).length
      #  next()
      #else
      #  res.send 401

exports.parse_ship_to = (v) ->
   zipcode_pattern = /(?:邮编[：:]?)?(\d{6})/
   zipcode = v.match(zipcode_pattern)
   v = v.replace(zipcode_pattern, "")
   name_pattern = /([^\s(（]+)[ \u3000]*[(（]?收[)）]?/
   name = v.match(name_pattern)
   address = v.replace(name_pattern, "").replace(/\n/g, "")
   zipcode = zipcode[1].trim() if zipcode
   name = name[1].trim() if name
   address = address.trim() if address
   str  = if address then address + '\n' else ''
   str += if zipcode then zipcode + ' ' else ''
   str += if name then "#{name}（收）" else ''
   str.trim()

exports.string_to_conditions = (str) ->
  # 小结与建议集合
  conditions = []

  # 匹配有分组情况或匹配没有分组情况
  pattern = /(?:[\#\＃]([^\#\＃\n]*)\n)?([^\#\＃]+)/g
  while match = pattern.exec str
    # 分组
    group = match[1]?.trim() or undefined

    # 小结建议集合
    conds = match[2]

    # 匹配每种小结与建议
    # 两种情况：1》存在小结但不存在建议
    # 2》存在小结和建议
    pattern_cond = /[>>》》]{2}([^\n]*)[\n]?((?:[^>>》》](\n)?)+)?(\n\n)?/g
    while match2 = pattern_cond.exec conds
      condition = {}
      condition.group = group

      # 小结
      cond = match2[1]?.trim()

      # 建议
      condition.description = match2[2]?.trim() or undefined
      
      # 级别
      level_pattern = /([ABC])级/
      level = cond.match level_pattern
      condition.level = level?[1]
      cond = cond.replace level_pattern, ""
      
      # 汇总名称
      summary_pattern = /[\{\｛]([^\{\｛\｝\}]*)[\｝\}]/
      condition.summary = cond.match(summary_pattern)?[1].trim() or undefined
      cond = cond.replace summary_pattern, ""
      
      # 症状名称（简称）
      name_pattern = /[\［\[\【]([^\［\【\[\]\】\］]*)[\]\】\］]/
      condition.name = cond.match(name_pattern)?[1].trim() or undefined
      cond = cond.replace(name_pattern, "").replace(/\(/g, '（')
      .replace(/\)/g, '）').trim()
     
      # 表达式
      exp_pattern = /([^\n]+)-[>》]/
      condition.expression = cond.match(exp_pattern)?[1].trim() or undefined
      cond = cond.replace(exp_pattern, "").trim()

      # 如果存在简称，那么剩余部分为详细描述
      # 否则，
      # 如果剩余部分存在括号内容，
      # 且剩余部分不等于除去括号及括号内容的剩余部分，
      # 则症状名称等于除去括号及括号内容的剩余部分
      # 详细描述为剩余部分。否则，症状名称为剩余部分
      detail_pattern1 = /\（([^\（\）]+(?:、[^\（\）]+)+)\）/g
      detail_pattern2 = /[\$]([^\$]*)[\$]/g
      cond = cond.replace(detail_pattern1, ($0, $1) ->
        '（'+ $1.replace(/[,，]/g, '、') + '）')
      cond = cond.replace detail_pattern2, ($0, $1) ->
        '$'+ $1.replace(/[,]/g, '，') + '$'
      cond = cond.replace(/[:：]/, "").replace(/[\\?]/g,"？")
      if condition.name
        condition.detail = cond
      else
        match1 = cond.match detail_pattern1
        match2 = cond.match detail_pattern2
        name = cond.replace(detail_pattern1, "").replace(detail_pattern2, "")
        condition.detail = if match1 or match2 then cond else undefined
        condition.name = if match1 or match2 then name else cond
      
      # 建议
      conditions.push(condition)
      
  conditions

exports.conditions_to_string2 = (conditions) ->
  return '' unless conditions?.length
  str = '<br><br>' if conditions.length
  group = ''
  for cond in conditions
    if cond.group and cond.group isnt group
      group = cond.group
      str += "<br>###### #{group}<br><br>"
    str += '+ '
    str += (cond.detail or cond.name) + '<br>'
  str
    #str += '<br><br>'


exports.conditions_to_string = (conditions) ->
  return '' unless conditions?.length

  # 匹配去括号及括号内容的详细描述
  detail_pattern1 = /[\（]([^\（\）]*)[\）]/g
  # 匹配去美元符合内容的详细描述
  detail_pattern2 = /[\$]([^\$]*)[\$]/g
  str = ''
  group = ''
  for cond in conditions
    # 如果存在分组且分组不为上一次的分组名称
    # 显示分组
    if cond.group and cond.group isnt group
      group = cond.group
      str += "# #{group}\n\n"
    str += '>> '
    # 级别
    str +=  cond.level + '级 ' if cond.level
    # 表达式
    str +=  cond.expression + ' ->' if cond.expression
    # 汇总名称
    str += '｛' + cond.summary + '｝' if cond.summary
    # 匹配去括号及括号内容和美元符号及符合里内容的详细描述
    if cond.detail
      detail = cond.detail.replace(detail_pattern1, "").replace detail_pattern2, ""
    # 如果去括号及括号内容的详细描述等于症状名称（简称）
    # 则只考虑显示详细描述
    # 否则如果存在症状名称且存在详细描述使用中括号显示症状名称，
    # 详细描述正常显示，如果存在症状名称但不存在详细描述，则不
    # 加中括号显示症状名称。
    if cond.name is detail
      str += cond.detail
    else
      str += if cond.detail then '［' + cond.name + '］' + cond.detail
      else cond.name
    # 建议
    str += '\n' + if cond.suggestion then cond.suggestion  + '\n\n' else '\n'
  str.trim()

exports.calibrate_precision = calibrate_precision = (lt, ut) ->
  return [lt, ut] unless lt and ut
  return [lt, ut] if isNaN(lt*1) or isNaN(ut*1)
  precision = Math.max.apply Math, [lt, ut].map (v) ->
    v.split('.')[1]?.length or 0
  [lt, ut].map (x) -> parseFloat(x).toFixed precision


exports.detail_to_expstr = (detail) ->
  detail = detail.replace(/[\?\？]/g, "((?:\\d{1,2}(?:\\.\\d)?)?)")
  detail_pattern1 = /（[^（）、]+(\、[^（）、]+)+）/g
  detail = detail.replace detail_pattern1, ($0, $1) ->
    $0.replace(/、/g, '|').replace(/（/g,'(').replace(/）/g, ')')
  detail_pattern2 = /[\$]([^\$]*)[\$]/g
  detail = detail.replace detail_pattern2, ($0, $1) ->
    ('((?:'+ $1.replace(/，/g, '|，') + ')?)')
  detail = '^' + detail + '$'
  detail

# 将md文件里的小结建议转化为对象
exports.string_to_conditions2 = (str) ->
  str = str.replace(/[\＃\#]/g, '#').replace(/》/g,'>')
  .replace(/｛/g, '{').replace(/｝/g,'}').replace(/\n[\s]*\n/g,'\n\n')
  suggestionGroup =
    name: ''
    suggestions: []
    suggestions_string: str
  pattern = /^\#([^\#\n]*)/
  suggestionGroup.name = str.match(pattern)?[1]?.trim() or ''
  pattern = /[\#]{1,}([^\n]*)[\n]?((?:[^\#\n](\n)?)+)?(\n\n)?/g
  # 去掉所有含有#号的段落
  str = str.replace(pattern, "")
  redirect_pattern = /[\{]([^\{\}]+)[\}]/
  repeat_pattern = /[\[]([^\[\]]+)[\]]/
  # 遍历每段小结建议
  for item in str.split('\n\n+')
    # 分隔小结和建议
    data  = item.split('\n\n')
    # 分隔所有并列的小结
    multi_conditions = data[0].split('\n+')
    if multi_conditions.length
      for single_condition in multi_conditions
        if single_condition.trim()
          names = single_condition.split('->')
          sug =
            conditions: []
            summary: {}
            content: data[1]?.trim()
          conditions = names[0]?.trim().replace(/[\s]/g,'').split('+')
          for condition in conditions
            redirect  = condition.match(redirect_pattern)?[1].trim() or undefined
            condition = condition.replace redirect_pattern, ""
            name = condition.match(repeat_pattern)?[1].trim()
            repeatable = if name then on else off
            name = name or condition
            sug.conditions.push name
          sug.summary.redirect = names[1]?.trim().match(redirect_pattern)?[1].trim() or undefined if names[1]?
          sug.summary.name = names[1]?.trim().replace redirect_pattern, "" if names[1]?
          console.log sug
          suggestionGroup.suggestions.push(sug)
  suggestionGroup

# # 建议语法处理引擎  
exports.string_to_suggestionGroup = (input) ->
  name = input.match(/^\#([^\#\n]*)/)?[1].trim()
  raw_suggestion_pattern = /((?:\+.*\n)+)\n((?:.+(?:\n)?)+)/g
  suggestions = while match = raw_suggestion_pattern.exec input
    # console.log match
    process_match match
  name: name
  suggestions: _.flatten _.flatten suggestions
  suggestions_string: input

exports.get_age_by_id = (id, check_date) ->
  birthday = id.substr(6,4) + "/" + Number(id.substr(10,2)) + "/" + Number(id.substr(12,2))
  age  = check_date.split('-')[0] - birthday.split('/')[0]
  birthday = new Date birthday
  date = birthday.setYear(birthday.getFullYear() + age)
  age  = if (date > new Date()) then age - 1 else age
  age

exports.get_sex_by_id = (id) ->
  id.substr(16, 1) % 2 ? "男" : "女"

process_match = (match) ->
  condition_lines = match[1]
  content = match[2].trim()
  condition_lines.trim().split('\n').map (line) ->
    combo_pattern = /[\<](.+)[\>]/
    if match = line.match(combo_pattern)
      combos = match[1]
      line = line.replace combo_pattern, ''
    [line, summary] = line.split('->')
    line = line.replace /[\｛\{](?:.+)[\}\｝]/g, ''
    process_match_line line, content, summary?.trim(), combos

process_match_line = (line, content, summary, combos) ->
  importance_pattern = /([A-Z])(\s)*\|/
  importance = line.match importance_pattern
  line = line.replace importance_pattern, ''
  segments = line.substr(1).trim().split('，').map (segment) ->
    if match = segment.match /[\（\(]((?:.+)(?:、.+)+)[\）\)]/
      process_input_combos match[1].split('、'), off
    else if match = segment.match /[\［\【]((?:.+)(?:、.+)+)[\］\】]/
      process_input_combos match[1].split('、'), on
    else if match = segment.match /可伴(.+)/
      process_input_combos [match[1]], on
    else
      [[segment]]
  total = segments.reduce ((memo, segment) -> memo * segment.length), 1
  cache = (segments[i+1..segments.length-1].reduce ((memo, segment) ->
    memo * segment.length), 1 for i in [0...segments.length])
  [0...total].map (i) ->
    conditions: segments.reduce ((memo, segment, j) ->
      memo.concat segment[~~(i / cache[j]) % segment.length]), []
    importance: importance?[1] or 'Z'
    content: content
    summary: if summary then name: summary else undefined
    combos: if combos then combos.split('、') else []

exports.process_input_combos = process_input_combos = (input, empty_allowed, inner_stage) ->
  return [[]] unless input.length
  result = process_input_combos input[1...input.length], empty_allowed, on
  result = result.map((x) -> [input[0]].concat x).concat(result)
  result = result[0...result.length-1] unless empty_allowed or inner_stage
  result
