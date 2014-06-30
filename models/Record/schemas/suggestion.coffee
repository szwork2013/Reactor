mongoose = require 'mongoose'
Schema   = mongoose.Schema

# 建议对应的所有症状    
condition_schema =
  # name:  医生选择的症状名称name
  # detail: 医生填写的详细症状
  # redirect: 在团体报告中用于汇总
  name       : String
  detail     : String
  redirect   : String
condition_schema = new Schema condition_schema

# 建议症状
suggestion_schema =
  combos: [String]
  content: String
  importance : String
  conditions: [condition_schema]
suggestion_schema = new Schema suggestion_schema

module.exports = suggestion_schema
