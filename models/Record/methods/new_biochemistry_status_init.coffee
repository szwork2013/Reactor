_      = require "underscore"
moment = require "moment"

module.exports = (record_schema) ->

  record_schema.statics.NEW_BIOCHEMISTRY_STATUS_INIT = () ->
    callback = arguments[0]
    date = moment().format('YYYY-MM-DD')
    commands = []
    commands.push '$match':
      'profile.notes':
        '$ne': '外检'
      '$or': [
        'appeared':
          '$ne': date
        'biochemistry_status':
          '$in': ['待检验', '已上机未完成', '待审核']
       ,
        'appeared': date
        'biochemistry_status':
          '$in': ['待检验', '已上机未完成', '待审核', '已完成']
       ,
        'biochemistry.audit.date_string': date
      ]
    commands.push '$project':
      appeared: 1
      biochemistry_status: 1
      barcode: 1
      profile: 1
      samplings: 1
      biochemistry: 1
      departments: 1
    commands.push '$unwind': '$departments'
    commands.push '$unwind': '$samplings'
    commands.push '$match':
      '$or': [
        'samplings.sampled.date_string':
          '$ne': date
        'biochemistry_status':
          '$in': ['待检验', '已上机未完成', '待审核']
       ,
        'samplings.sampled.date_string': date
        'biochemistry_status':
          '$in': ['待检验', '已上机未完成', '待审核', '已完成']
       ,
        'biochemistry.audit.date_string': date
      ]
      'samplings.status': '已采样'
      # 'samplings.biochemistry': on
      'samplings.apps': '生化'
      'departments.name': '生化检验'
    commands.push '$group':
      _id: '$barcode'
      barcode:
        $first : "$barcode"
      profile:
        $first : "$profile"
      biochemistry:
        $first : "$biochemistry"
      departments:
        $first : "$departments"
      sample_date:
        $first : "$samplings.sampled.date_string"
    @aggregate commands, (error, records) ->
      return callback error if error
      result = []
      for record in records
        person =
          barcode: record.barcode
          profile:
            name: record.profile.name
            sex:  record.profile.sex
            age:  record.profile.age
          plate_hole: record.biochemistry?.disk_and_position or ''
          approval_date: record.biochemistry?.audit?.date_string or ''
          sample_date: record.sample_date
          items: record.departments.items
          status: record.departments.status
        result.push person
      callback null, result
