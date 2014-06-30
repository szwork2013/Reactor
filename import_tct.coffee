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
      itemnames = data.filter (value,key) -> key>0
      return
    result = 
      barcode: data.splice(0,1)[0]
      entries:  (data.map (value,key) -> {name: itemnames[key]?.trim(), normal: value}).filter (item) -> item.name and item.normal and item?.normal?.trim() not in ['√', '无']
    return result
  ).on('record', (data, index) ->
    raw_data.push data
    raw_rows += data.entries.length
  )
  .on('end', (count) ->
    # 对原始数据按照条码编号进行分组
    Record.import_multi_tct raw_data, department_name, doctor_name, (error, raw_items, valid_items, total_groups) ->
      return console.error error if error
      valid_rows = valid_items
      console.log "共有#{raw_rows}个项目，已导入#{valid_rows}个项目，未导入#{raw_rows - valid_rows}个项目。"
  ).on('error', (error) -> console.error error.message)

  process.on 'exit', () ->
    console.log "共有#{raw_rows}个项目，已导入#{valid_rows}个项目，未导入#{raw_rows - valid_rows}个项目。"
