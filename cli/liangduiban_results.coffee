mongoose     = require 'mongoose'
fs           = require 'fs'
models       = require "../models"
subdomain    = 'hswk.healskare.com'
_            = require "underscore"

models subdomain, (error, models, settings) ->
  return console.error error if error
  {Record} = models
  console.log process.argv[2]
  str = '姓名,部门,乙肝病毒表面抗原,乙肝病毒表面抗体,乙肝病毒e抗原,乙肝病毒e抗体,乙肝病毒核心抗体\n'
  Record.find('profile.source': process.argv[2])
  .exec (error, records) ->
    return console.log error if error
    for record in records
      for department in record.departments
        if department.name is '免疫检验'
          found_item1 = _.find department.items, (item) -> item.name is '乙肝病毒表面抗原'
          found_item2 = _.find department.items, (item) -> item.name is '乙肝病毒表面抗体'
          found_item3 = _.find department.items, (item) -> item.name is '乙肝病毒e抗原'
          found_item4 = _.find department.items, (item) -> item.name is '乙肝病毒e抗体'
          found_item5 = _.find department.items, (item) -> item.name is '乙肝病毒核心抗体'
          str += record.profile.name + ',' + (record.profile.division or '') + ',' + (found_item1?.value or '') + ',' + (found_item2?.value or '') + ',' + (found_item3?.value or '') + ',' + (found_item4?.value or '') + ',' + (found_item5?.value or '') + '\n'
    fs.writeFileSync('yigan.csv', str, 'utf-8')
    process.exit()
