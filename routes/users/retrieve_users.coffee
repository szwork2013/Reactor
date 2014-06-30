# 对用户进行查询
#
# ## 获取用户信息
#   + **资源地址**
#   + `/users?fields={fields}&skip={skip}`
#   + **例**
#     * /users?fields=_id,name&limit=20
#    [
#      {
#        _id: '506036b8fdeedc3e31000006',
#        name: "test"
#      }
#    ]
# ## 数据服务（应用于修改批次注册人）
#   + 根据条件查询数据
#   + 查询成功返回数组`users`，失败发送错误信息。

app.get '/users', authorize('cashier'), (req, res) ->
  {User} = req.models
  User.find()
  .select(req.query.fields?.replace(/,/g, ' '))
  .skip(req.query.skip)
  .limit(req.query.limit)
  .exec (error, users) ->
    return res.send 500, error.stack if error
    res.send users
