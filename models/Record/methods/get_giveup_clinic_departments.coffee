_ = require 'underscore'

module.exports = (record_schema) ->
  
  record_schema.methods.get_giveup_clinic_departments = () ->
    giveup_clinic_departments = @departments.filter((d) ->
      d.status is '放弃' and not d.name.match(/(腹部|颈部)彩超/) and d.category is 'clinic')
      .map (d) -> d.name
    abdomen_caichao = _.find @departments, (d) ->
      d.name is '腹部彩超'
    neck_caichao    = _.find @departments, (d) ->
      d.name is '颈部彩超'
    fubu_items = ['肝', '胆', '胰', '脾', '肾']
    if abdomen_caichao?.items?.filter((item) -> item.name in fubu_items).every((item) -> item.status is '放弃')
      giveup_clinic_departments.push '腹部彩超'
      abdomen_caichao.items = abdomen_caichao.items.filter (item) -> item.name not in fubu_items
    if abdomen_caichao?.items?.some((item) -> item.status is '放弃' and item.name.match(/前列腺/))
      giveup_clinic_departments.push '前列腺彩超'
      abdomen_caichao.items = abdomen_caichao.items.filter (item) -> item.name isnt '前列腺'
    if abdomen_caichao?.items?.some((item) -> item.status is '放弃' and item.name.match(/子宫附件/))
      giveup_clinic_departments.push '子宫附件彩超'
      abdomen_caichao.items = abdomen_caichao.items.filter (item) -> item.name isnt '子宫附件'
    if neck_caichao?.items
      for item in neck_caichao.items
        giveup_clinic_departments.push(item.name + '彩超') if item.status is '放弃'
    giveup_clinic_departments
