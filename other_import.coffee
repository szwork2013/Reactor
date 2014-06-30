
_            = require 'underscore'
csv          = require 'csv'
mongoose     = require 'mongoose'
fs           = require 'fs'
models       = require "./models"
subdomain    = 'hswk.healskare.com'


# 定义原始id,和对应其标题集合;
origin = [
  (id: 'id',    titles: ['体检编号', '采血管编号', '条码', '条码编号', '编号'])
  (id: 'name',  titles: ['项目', '项目名称', '名称'])
  (id: 'value', titles: ['值', '结果', '数值'])
  (id: 'unit',  titles: ['单位', '单位'])
  (id: 'ut',    titles: ['上限', '参考上限'])
  (id: 'lt',    titles: ['下限', '参考下限'])
]

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record, Department,Product, SuggestionGroup} = models

  doctor_name   = process.argv[4] or ''
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
      for column, col_index in data
        columns[col_index] = _.find(origin, (origin_column) ->
          column in origin_column.titles)?.id
      return
    raw_rows++
    return data.reduce (result, cell, cell_index) ->
      result[columns[cell_index]] = cell if columns[cell_index]
      result
    , {}
  ).on('record', (data, index) ->
    itemnames.push data.name if data.name not in itemnames
    raw_data.push data if data and data.id and data.name and data.value
  )
  .on('end', (count) ->
    department = Department.cached_departments_hash[department_name]
    keys =  _.keys department.items_hash
    not_exists_names = itemnames.filter (name) -> name.toUpperCase() not in keys
    if not_exists_names.length
      console.log '要导入的' + not_exists_names.join() + '在' + department_name + '中不存在。'
    results = []
    grouped_data  = _.groupBy raw_data, "id"
    for key, value of grouped_data
      results.push { barcode: key, entries: value}
    # 对原始数据按照条码编号进行分组
    Record.import_multi_records_entries results, department_name, doctor_name, (error, raw_items, valid_items, total_groups) ->
      return console.error error if error
      valid_rows = valid_items
      console.log "共有#{raw_rows}个项目，已导入#{valid_rows}个项目，未导入#{raw_rows - valid_rows}个项目。"
  ).on('error', (error) -> console.error error.message)
  process.on 'exit', () ->
    console.log "共有#{raw_rows}个项目，已导入#{valid_rows}个项目，未导入#{raw_rows - valid_rows}个项目。"
