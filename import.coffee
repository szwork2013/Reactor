# 对实验室项目结果进行导入
#
# ## 处理逻辑
#  + 将CSV文件的标题在`origin`中找对应的标题id，按顺序存放到`real_names`，形式如下：
#    * [ { id: 'id' },{ id: 'name' },{ id: 'value' },{ id: 'unit' },{ id: 'lt' },{ id: 'ut' } ]
#  + 读取CSV文件项目结果数据组装存放到`lisimport_data`，形式如下：
#      [
#       {
#        "id": ObjectId("4e5bb37258200ed9aabc5d65"),
#        "name":"项目A2",
#        "value":"50",
#        "unit":"umol/l",
#        "lt":"60",
#        "ut":"80"
#       },
#        ......
#      ]
#  + 查询lisimport_data中所有id对应的个人档案信息，如果存在档案信息`record_data`，处理如下：
#    * 查询所有科室信息`room_data`，方便使用项目的小结建议 
#      * 对`lisimport_data`的同一档案编号进行分组成`grouped_data`
#      * 循环遍历个人档案信息`record_data`
#      * 获取该当前档案编号下需要覆盖的项目信息`items`，遍历需要覆盖的项目信息`data`，
#      * 查找导入项目`data`在个人档案项目`section.items`中是否是存在和已付费的项目，如果在个人档案中存在该项目`item`则进行覆盖和结果处理，处理如下：
#        * 找到导入项目`data`在科室中对应的项目`found_item`
#        * 导入项目中单位、上限、下限如果有值则覆盖到档案中的项目，如果档案中项目的单位、上限、下限不存在则取科室`room_data`项目的对应值
#        * 调用`calc_threadshold`计算上下限，参数为表达式和个人基本信息
#        * 调用`calc_conditions`计算结果值，参数为`found_item`的初始小结建议和个人档案的个人基本信息，将计算结果值覆盖到档案中的项目
#        * 如果档案中有科室的项目发生改变`roomchanged=true`，对科室下有表达式的项目调用`calc_value`计算项目表达式得到结果值,那么调用`set_room_finished`更新科室检查完成情况`finished`，更新检查医生`doctors`
#        * 如果档案发生改变`recordchanged=true`，那么调用`set_record_finished`更新个人档案检查完成情况`finished`，并且将改动后的档案信息更新到数据库中。
#  + 如果有项目导入成功，提示'一共导入了`num`个项目。' ,  如果没有项目导入，提示'没有导入项目。`
_            = require 'underscore'
csv          = require 'csv'
mongoose     = require 'mongoose'
fs           = require 'fs'
models       = require "./models"
subdomain    = 'hswk.healskare.com'

models subdomain, (error, models, settings) ->
  return console.error error if error
  require './workers'
  {Record, Department,Product, SuggestionGroup} = models
  # 定义原始id,和对应其标题集合;
  origin = [
    (id: 'id',    titles: ['体检编号', '采血管编号', '条码', '条码编号', '编号'])
    (id: 'name',  titles: ['项目', '项目名称', '名称'])
    (id: 'value', titles: ['值', '结果', '数值'])
    (id: 'unit',  titles: ['单位', '单位'])
    (id: 'ut',    titles: ['上限', '参考上限'])
    (id: 'lt',    titles: ['下限', '参考下限'])
  ]

  doctor_name   = process.argv[4] or '李晓明'
  department_name  = process.argv[3] or '尿常规'

  raw_rows = 0
  valid_rows = 0

  # 存储当前表格各个列对应键
  # ['id', 'name', 'value', 'unit', 'lt', 'ut']
  columns = []

  # 存储当前表格数据。
  # {id:'12345', name:'项目A',value:'123'}
  raw_data = []

  itemnames = []

  csv()
  .from.path(process.argv[2])
  .transform((data, row_index) ->
    if row_index is 0
      itemnames = data.filter (value,key) -> key>0
      return
    result = 
      barcode: data.splice(0,1)[0]
      entries:  (data.map (value,key) -> {name: itemnames[key]?.trim(), value: value}).filter (item) -> item.name and item.value and item?.value?.trim() not in ['√', '无']
    return result
  ).on('record', (data, index) ->
    raw_data.push data
    raw_rows += data.entries.length
  )
  .on('end', (count) ->
    department = Department.cached_departments_hash[department_name]
    keys =  _.keys department.items_hash
    not_exists_names = itemnames.filter (name) -> name.toUpperCase() not in keys
    if not_exists_names.length
      console.log '要导入的' + not_exists_names.join() + '在' + department_name + '中不存在。'
    console.log JSON.stringify raw_data, 'raw_data'
    # 对原始数据按照条码编号进行分组
    Record.import_multi_records_entries raw_data, department_name, doctor_name, (error, raw_items, valid_items, total_groups) ->
      console.error error if error
      valid_rows = valid_items
      console.log "共有#{raw_rows}个项目，已导入#{valid_rows}个项目，未导入#{raw_rows - valid_rows}个项目。"
  ).on('error', (error) -> console.error error.message)

  process.on 'exit', () ->
    console.log "共有#{raw_rows}个项目，已导入#{valid_rows}个项目，未导入#{raw_rows - valid_rows}个项目。"
