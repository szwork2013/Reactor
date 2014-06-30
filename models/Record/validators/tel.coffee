
module.exports = (v) ->
  # 电话号码验证
  # 有效的移动电话或固话（7或8位可配置）（可能含区号或分机号）
  pattern_tel = /^(0?1[3-8](\d){9}|(0(\d){2,3}-)?(\d){7,8}(-(\d){1,6})?)$/
  return not v or pattern_tel.test(v)
