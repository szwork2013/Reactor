# 保存TCT结果数据
#
# ## 根据客人编号保存客人TCT结果数据
#   + **资源地址**
#   + `/records/departments/import_tct_results`
#     `req.body`
#     * `text`：word文档数据
#     * `image`：图片数据
#   + **例**
#     *`/records/departments/import_tct_results`
#
#   + **返回响应正文**
#     * {}

# ## 数据服务（应用于tct结果数据导入）
#   + 匹配word文档数据，文档中的申请号为barcode
#   + 匹配word文档中诊断和镜下所见之间的文字为小结
#     * 当小结为一行时，如果值是`未见上皮内病变和癌细胞`，
#       那么结果是正常情况为`未见上皮内病变和癌细胞`
#     * 当小结为两行时，如果第一行是`未见上皮内病变和癌细胞`，
#       第二行为`(轻度炎症)`等，那么结果`name`为`轻度炎症`，
#       `_name`为`未见上皮内病变和癌细胞(轻度炎症)`
#     * 当小结为多行，且第一行不是`未见上皮内病变和癌细胞`，
#       那么针对每行去括号后的数据匹配科室项目里的小结，
#       如果能匹配上，则将匹配上的结果添加到客人档案对应项目结果中。
#   + 修改档案信息
#   + 修改成功返回{}，失败发送错误信息。
_       = require 'underscore'
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
fs       = require 'fs'

# TODO: 设计一下API的依赖关系，争取少重复我们自己。
# /records/:barcode/departments/:name/import_result
# /records/:barcode/departments/宫颈超薄细胞学检查/import_result
# 影响前端修改，暂不
app.post '/records/departments/import_tct_results'
, ({host: host, models: models, body: {text, image}}, res) ->
  barcode_pattern = /申请号[:：]([^\r\n]*)\r\n/
  barcode = text.match(barcode_pattern)[1].trim()
  diagnose_pattern = /诊[\s]*断[:：]([\s\S]*)\r\n镜下所见/
  diagnose = (text.match(diagnose_pattern)[1].split('\r\n')
             .map (x) -> x.trim())
             .filter (y) -> y
  {Record, Department} = models
  barcode = if barcode.length is 10 then barcode.substr(0,barcode.length-2) else barcode
  query = barcode: barcode
  # 由于import_single_record_entries不提示错误所以先查询文档提示404
  Record.findOne(query)
  .select('barcode')
  .exec (error, record) ->
    return res.send 500, error,stack if error
    return res.send 404, '未找到档案' unless record
    original_department = Department.clone '宫颈超薄细胞学检查'
    original_item = original_department.items_hash['宫颈超薄细胞学检查']
    id  = new ObjectId
    buf = new Buffer image, 'base64'
    fs.writeFileSync "./public/images/#{id}.jpeg", buf
    image2 =
      _id: id
      tag: '宫颈超薄细胞学检查:tct'

    item =
      _id: original_item._id
      name: '宫颈超薄细胞学检查'
      images: [image2]
      category: original_item.category

    if diagnose[0] is original_item.default
      if diagnose.length is 1
        item.normal = original_item.default
      else
        condition = _.find original_item.conditions, (condition) ->
          condition.name is '子宫颈TCT' + diagnose[1].replace /[\(\（\)\）]/g, ""
        if condition
          condition.detail = diagnose.join('')
          item.conditions = [condition]
        else
          item.normal = diagnose.join('')
    else
      item.conditions = original_item.conditions.filter (condition) ->
        condition.name in (diagnose.map (name) -> '子宫颈TCT' + name.replace /[\(\（\)\）]/g , "")
    single_record_entries =
      barcode: barcode
      entries: [item]
    Record.import_single_record_entries single_record_entries, '宫颈超薄细胞学检查', '刘津京'
    , (error, according_items) ->
      return res.send 500, error.stack if error
      res.send {}

