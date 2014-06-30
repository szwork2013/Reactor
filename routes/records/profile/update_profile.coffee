# 修改客人基本信息
#
# ## 修改客人基本信息
#   + **资源地址**
#   + `/records/:barcode/profile`
#   + **例**
#     *  /records/10000001/profile
#     * `req.body`内容分别如下：
#       {
#         name:'name',
#         sex:'男', 
#         age:25,
#         id:'421023198806030445',
#         .....
#       }
# ## 数据服务（应用于个人注册修改客人基本信息）
#   + 根据档案编号更新档案基本信息
#   + 修改成功后返回{}，失败发送错误信息。
moment   = require "moment"

app.put '/records/:barcode/profile', authorize('cashier'), (req, res) ->
  {Record}  = req.models
  {barcode} = req.params
  Record.barcode req.params.barcode, (error, record) ->
    console.log error if error
    return res.send 500, error.stack if error
    return res.send 404 unless record
    sex_modified = if record.profile.sex isnt req.body.sex then on else off
    is_waijian   = if '外检' in record.profile.notes then on else off
    isnt_waijian = if '外检' in req.body.notes then off else on
    if is_waijian and isnt_waijian
      for sampling in record.samplings
        sampling.status = 'unsamped'
        sampling.sampled = undefined
    for key, value of req.body
      record.profile[key] = value
    record.update_guidance_card_hash (error) ->
      console.log error if error
      return res.send 500, error.stack if error
      record.save (error) ->
        console.log error if error
        return res.send 500, error.stack if error
        res.send {}
        if sex_modified
          Record.barcode req.params.barcode, (error, record) ->
            console.log error if error
            return res.send 500, error.stack if error
            return res.send 404 unless record
            for depart in record.departments
              depart.items = depart.items.filter (item) ->
                (item.sex? and item.sex is req.body.sex) or not item.sex?
            record.departments = record.departments.filter (d) -> d.items.length
            record.save (error, doc) ->
              console.log error if error
              return console.log 500, error.stack if error
