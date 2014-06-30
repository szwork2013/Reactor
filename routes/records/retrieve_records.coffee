# 对个人档案查询
#
# ## 获取的个人档案信息
#   + **资源地址**
#   + `records?keywords={keywords}`
#     * `keywords`：检索条件
#   + **例**
#     * 根据身份证号或姓名查询档案【拍身份证出导检卡】
#      `records?keywords=姓名:王六一,性别：male,身份证号:421023198806030445`
#     * 在检索文本框内输入姓名、拼音、身份证号、barcode
#      `records?keywords=张三`
# ## 数据服务（应用于个人注册的查询功能、拍身份证检索档案）
#   + 根据条件查询数据
#   + 查询成功返回数据，失败发送错误信息。

app.get '/records', authorize('cashier'), (req, res) ->
  {keywords, department_names, biochemistry} = req.query
  return res.send [] if req.query.keywords is ''
  callback = (error, records) ->
    return res.send 500, error.stack if error
    res.send records.sort (pre, next) ->
      if pre.profile.check_date < next.profile.check_date or
        (pre.profile.check_date is next.profile.check_date and pre.status?.appeared?) then 1 else -1
  params = []
  params.push keywords
  param = {}
  param['department_names'] = department_names if department_names
  param['biochemistry'] = biochemistry if biochemistry
  params.push param
  params.push callback
  req.models.Record.search params...
