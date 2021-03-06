# 保存放射科胸部正位片项目结果数据
#
# ## 根据客人编号保存客人胸部正位片结果数据
#   + **资源地址**
#   + `/records/:barcode/departments/import_radiology_results2`
#     `req.body`
#     * `image`： 图片数据
#     * `detail`：详细描述
#     * `conditions`：症状
#   + **例**
#     *`/records/00000096/departments/import_radiology_results2`
#
#   + **返回响应正文**
#     * {}

# ## 数据服务（应用于放射科结果数据导入）
#   + 导入放射科胸部正位片结果数据
#   + 修改成功返回{}，失败发送错误信息。
_       = require 'underscore'

# TODO: 放射科暂时仅支持胸部正位片，争取改进。
# /records/:barcode/departments/:name/import_result
# /records/:barcode/departments/放射科/import_result
# 影响前端修改，暂不改

mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
fs       = require 'fs'

app.post '/records/:barcode/departments/import_radiology_results2'
, ({params: {barcode}, host: host, models: models, body: {name, tag, detail, conditions}}, res) ->
  {Record, Department} = models
  query = barcode: barcode
  #由于import_single_record_entries不提示错误所以先查询文档提示404
  Record.barcode barcode, (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404 unless record
    original_department = Department.clone '放射科'
    department = _.find record.departments, (department) -> department.name is '放射科'
    items = []
    for item in department.items
      if tag.match(/胸部/)
        continue unless item.name.match(/胸部/)
      if tag.match(/颈椎/)
        continue unless item.name.match(/颈椎/)
      if tag.match(/腰椎/)
        continue unless item.name.match(/腰椎/)
      import_item =
        _id: item._id
        name: item.name
        category: item.category
        description: detail.trim()
      original_item = original_department.items_hash[item.name]
      if conditions.match(/未见.*/) #in ['心肺未见异常', '胸部正位像心肺未见异常', '颈椎相未见异常']
        import_item.normal = original_item.default
      else
        import_item.conditions = [{name: item.name, detail: conditions}]
      items.push import_item
    single_record_entries =
      barcode: barcode
      entries: items
    Record.import_single_record_entries single_record_entries, '放射科', name
    , (error, according_items) ->
      return res.send 500, error.stack if error
      res.send {}
