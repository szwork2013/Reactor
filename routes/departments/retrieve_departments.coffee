# 对科室进行查询
#
# ## 获取科室信息
#   + **资源地址**
#   + `/departments?category={category}&fields={fields}&skip={skip}&limit={limit}&mydepartments={myrooms}`
#   + **例**
#     获取临床科室信息
#     `/departments?category=clinic&fields=order,name,default,image_path`
#     获取实验室科室信息
#     `/departments?category=laboratory&fields=order,name,default,image_path,items&names=生化检验,无机盐`
#     获取医生检查科室信息
#     `/departments?fields=name,items.conditions.name,items.conditions.detail&mydepartments=true`
#   + **返回响应正文**

# ## 数据服务（应用于科室查询）
#   + 根据条件查询数据
#   + 查询成功返回数组`departments`，失败发送错误信息。
fs = require 'fs'
_  = require "underscore"
{conditions_to_string} = require "../../utils/util.coffee"

app.get '/departments', authorize('mo', 'admin'), (req, res) ->
  {category, fields, skip, limit, names} = req.query
  {Department, User} = req.models
  conditions = {}
  if names
    conditions['name'] = '$in': names.split(',').map (name) -> name.trim() 
  mydepartments_hasnt_xdt = off
  get_departments = ->
    query = Department.find(conditions)
    query.where('category').equals(category) if category
    query.skip(skip) if skip
    query.limit(limit) if limit
    query.sort('order')
    query.select(fields.replace /,/g, ' ') if fields
    query.exec (error, departments) ->
      return res.send 500, error.stack if error
      departments = departments.map (d) -> d.toObject()
      department = _.find departments, (d) -> d.name is '心电图'
      department.attach = on if mydepartments_hasnt_xdt
      department.items = [] if 'nurse' in (req.user?.roles or [])
      res.send departments

  nurse_departments = [
    '身高体重'
    '血压'
    '腰臀比'
    '体脂率'
    '心电图'
  ]
  if req.query.mydepartments?
    User.findById(req.user?._id)
    .select('roles departments')
    .exec (error, user) ->
      return res.send 500, error.stack if error
      roles = user?.roles or []
      if 'nurse' in roles
        conditions.name = '$in': nurse_departments
      else if 'doctor' in roles
        # if Department.clone('心电图')._id.toString() not in user.departments.map((d) -> d.toString())
          # mydepartments_hasnt_xdt = on
          # user.departments.push Department.clone('心电图')._id
        conditions._id = '$in': user.departments
      get_departments()
  else
    get_departments()

