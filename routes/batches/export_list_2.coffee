# 导出批次客人名单
#
# ## 根据批次编号获取客人名单
#   + **资源地址**
#   + `/batches/:batch_id/guest_list.xls2`
#   + **例**
#     * /batches/123456789/guest_list.xls2
#     [{
#        name: '部门',
#        cells: [
#          ["姓名","性别","年龄","套餐","到场日期","状态"],
#          ["王六一","女","20","小套餐","2013-01-02","未到场|待出报告|已出报告"]
#        ]
#      }]
# ## 数据服务（应用于获取某批次下的客人名单）
#   + 根据条件查询数据
#   + 查询失败发送错误信息。
_       = require "underscore"
request = require "superagent"

app.get '/batches/:batch_id/guest_list2.xls', authorize('mo', 'admin'), (req, res) ->
  {batch_id} = req.params
  return res.send 404 if not batch_id?.match /[0-9a-f]{24}/
  req.models.Record.find()
  .where('profile.batch').equals(batch_id)
  .select('barcode profile orders appeared printed_complete')
  .exec (err, records) ->
    return res.send 500, err.stack if err
    console.log records.length, 'records.length'
    print_records = records.reduce (memo, record) ->
      packages = record.orders.filter (order) ->
        order.category is 'package'
      package_name = if packages[packages.length-1]?.name?.match(/.*\（(.*)\）/) then packages[packages.length-1]?.name?.match(/.*\（(.*)\）/)?[1] else packages[packages.length-1]?.name
      if record?.printed_complete?._id or ('电子报告' in record.profile.notes and record.status is '已完成')
        status = '已出报告'
      else if record.appeared.length
        status = '待出报告'
      else
        status = '未到场'
      memo.push
        barcode: record.barcode
        name: record.profile.name
        sex: record.profile.sex # is 'male' then '男' else '女'
        age: record.profile.age
        division: record.profile.division or '其他'
        package: package_name
        appeared: record.appeared[0] or ''
        notes: record.profile.notes.join('')
        status: status
      memo
    , []
    appeared_records = print_records.filter((record) -> record.status in ['已出报告', '待出报告'])
      .sort (a, b) -> if a.division > b.division then 1 else -1
    unappeared_records = print_records.filter((record) -> record.status is '未到场')
      .sort (a, b) -> if a.division > b.division then 1 else -1
    wait_print_records = []
    appeared_guests = appeared_records.reduce (memo, item) ->
      memo.push [item.barcode, item.name, item.sex, item.age, item.package, item.appeared, item.division, item.notes, item.status]
      memo
    , []
    appeared_guests.unshift ["编号", "姓名","性别","年龄","套餐","到场日期", "部门", "备注", "状态"]
    wait_print_records.push
      Name: '到场客人'
      Cells: appeared_guests
    unappeared_guests = unappeared_records.reduce (memo, item) ->
      memo.push [item.barcode, item.name, item.sex, item.age, item.package, item.division, item.notes, item.status]
      memo
    , []
    unappeared_guests.unshift ["编号", "姓名","性别","年龄","套餐", "部门", "备注", "状态"]
    wait_print_records.push
      Name: '未到场客人'
      Cells: unappeared_guests

    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify(wait_print_records))
    .set('Content-Type', 'text/plain')
    .end (res2) =>
      res.redirect res2.text
