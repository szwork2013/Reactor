# 尿常规结果保存
#
# ## 
#   + **资源地址**
#   + `/records/departments/urine_routine`
#   + `req.body`
#     [
#      {
#        "barcode": "111",
#        "entries": [
#          { name: "项目1", value:'12'},
#          { name: "项目2", value:'45'}
#          ]
#      },
#       ......
#     ]
#   + **返回响应正文**
#     * {}
# ## 数据服务（应用于尿常规结果保存）
#   + **处理过程**
#    - 保存尿常规结果

# TODO: Deprecated API，使用普适接口实现。
# '/records/:record_id/departments:/:尿常规科室编号'
# 与医生工作站的API相同。
app.put '/records/departments/urine_routine', authorize('doctor'), (req, res) ->
  req.models.Record.import_multi_records_entries req.body, '尿常规', req.user.name
  , (error, raw_items, valid_items, total_groups) ->
    return res.send 500, error.stack if error
    res.send {}
