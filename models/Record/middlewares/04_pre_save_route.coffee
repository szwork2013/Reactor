# 路线设置
# 尚无路线，或者基本信息变更且路线不再匹配时，根据基本信息随机匹配路线。
module.exports = (record_schema) ->
  record_schema.pre 'save', on, (next, done) ->
    next()
    # TODO：团检注册时，@route没有populate。解决之后删除match之后的问号。
    if not @route or @isModified('profile') and not @route.match?(@profile)
      @route = @model('Route').random(@profile)
    done()
