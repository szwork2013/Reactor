moment = require "moment"
_      = require "underscore"

module.exports = (record_schema) ->
  # 服务于个人注册检索和拍身份证
  record_schema.statics.search = () ->
    if arguments.length is 2 and 'function' is typeof arguments[1]
      keywords = arguments[0]
      cb       = arguments[1]
    else if arguments.length is 3 and 'function' is typeof arguments[2]
      keywords = arguments[0]
      {department_names, biochemistry} = arguments[1]
      cb       = arguments[2]
    names = department_names?.split(',') or []
    keywords_pattern = /姓名[:：]([^,，]*)[,，]性别[:：]([^,，]*)[,，]身份证号[:：]([^,，]*)/
    match = keywords?.match keywords_pattern
    keywords_pattern2 = /姓名[:：]([^,，]*)[,，]身份证号[:：]([^,，]*)/
    match2 = keywords?.match keywords_pattern2
    id = (if match then match?[3] else match2?[2]) or ''
    {cached_departments_hash} = @model('Department')
    ids = names.map((name) -> cached_departments_hash[name]._id.toString())
    if id.length is 18
      year = id.substr(6,4)
    else if id.length is 15
      year = '19' + id.substr(6,2)
    if keywords
      criteria = if (match)
        '$or':
          [
            'profile.name': match[1]
            'profile.sex': match[2]
            'profile.id': '#'
          ,
            'profile.id': match[3]
          ]
      else if (match2)
        '$or':
          [
            'profile.name': match2[1]
            'profile.id': '#'
          ,
            'profile.id': match2[2]
          ]
      else
        '$or':
          [
            ('profile.name': new RegExp "^#{keywords.replace(/[\*\＊]/g, '(.*)').replace(/[?？]/g, '(.{1})')}$")
            ('profile.name_pinyin': new RegExp "^#{keywords.toUpperCase().replace(/[\*\＊]/g, '(.*)').replace(/[?？]/g, '(.{1})')}$")
            ('profile.id': keywords)
            ('profile.tel': keywords)
            ('barcode': keywords)
          ]

    find_select = @find(criteria)
    .select('barcode appeared field_complete report_complete report_complete_date printed_date')
    .select('profile.name profile.sex profile.age profile.source')
    .select('biochemistry samplings guidance_card_printed')
    .select('status profile.check_date profile.check_time registration')
   
    find_select = find_select.select('departments') if names.length
    find_select = find_select.select('biochemistry_status') if biochemistry

    find_select.sort('-registration.date')
    find_select.limit(100)
    .exec (error, records) ->
      return cb error if error
      if year
        for r in records
          if r.profile.age isnt '#'
            r.span = (moment(r.registration.date).format('YYYY') - r.profile.age) - year
        records = records.filter (record) -> not record.span? or Math.abs(record.span) <= 5
      if names.length
        for record in records
          record.departments = record.departments.filter (department) ->
            department._id.toString() in ids
      records = records.map (record) -> record.toJSON()
      for record in records
        if biochemistry
          record.approval_date = record.biochemistry?.audit?.date_string or ''
          bio_sampling = _.find record.samplings, (sampling) -> sampling.tag is '生化'
          record.sample_date = bio_sampling?.sampled?.date_string or ''
          delete record.departments
        delete record.biochemistry
        delete record.samplings
        delete record.unfinished_departments
      if biochemistry
        records = records.filter (record) -> record.biochemistry_status isnt '未付费'
      cb null, records
