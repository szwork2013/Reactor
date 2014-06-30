mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
event    = require "../../Shared/event.coffee"

sampling_schema =
  # 样本识别码,由8位barcode和2位样本种类组成
  _id: String

  # TODO: 键名改为sampled
  sampled: event
  
  # 标记使用相同样本的不同科室
  tag: String
  
  # 样本名称
  name: String
  
  # 样本状态(中文:未采样,已采样,未付费,已删除)
  # TODO: 替换本行代码 
  # status:{type:String, default: '未采样'}
  # enum: ['unsampled', 'sampled', 'unpaid', 'invalid']
  # enum: ['未采样', '已采样', '未付费', '已删除']
  status: {type: String, default: '未采样'}
  
  # 样本用途
  # TODO: 布尔变量名是 is_biochemistry 还是 isBiochemistry ?
  # TODO: 应用（app），枚举于：生化、免疫、血常规等严格采样且提供应用的设备中。
  # TODO: 目前仅标记：生化。
  # TODO: 改结构为apps['biochemistry',...]
  biochemistry: Boolean
  apps: [String]

# 显示样本颜色
colors =
  '黄色采血管（1）': '#FFA54F'
  '黄色采血管（2）': '#FFA54F'
  '黄色采血管（3）': '#FFA54F'
  '紫色采血管（1）': '#912CEE'
  '绿色采血管（1）': '#008B45'
  '绿色采血管（2）': '#008B45'
  '黑色采血管': '#000000'
  '蓝色采血管': '#0000FF'

sampling_schema = new Schema(sampling_schema,{versionKey: off, id: off})

sampling_schema.virtual('lines').get ->
  {name, sex, age} = @ownerDocument().profile
  [name, "#{sex}　#{age}", @tag or @name]

sampling_schema.virtual('barcode').get ->
  @_id

sampling_schema.virtual('color').get ->
  if colors[@name] then colors[@name] else undefined

transform = (doc, ret, options) ->
  # delete ret.tag
  delete ret.biochemistry
  delete ret.departments
  delete ret.apps
  delete ret.sampled?.user_id
  delete ret.sampled?.date_number
  ret.sampled?.user = ret.sampled?.user_name
  ret.sampled?.date = ret.sampled?.date_string
  delete ret.sampled?.user_name
  delete ret.sampled?.date_string
  ret

sampling_schema.set 'toJSON', {virtuals: on, transform: transform}
# sampling_schema.options.toJSON.transform = transform


module.exports = sampling_schema
