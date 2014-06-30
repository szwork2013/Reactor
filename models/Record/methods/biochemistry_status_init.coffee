_   = require "underscore"

module.exports = (record_schema) ->

  record_schema.statics.BIOCHEMISTRY_STATUS_INIT = () ->
    if arguments.length is 2 and 'function' is typeof arguments[1]
      date = arguments[0]
      callback = arguments[1]
    else
      return callback new Error "参数不正确"
    commands = []
    commands.push '$match':
      '$or': [
        'samplings.sampled.date_string': date
       ,
        'biochemistry.analyze_start.date_string': date
      ]
      'samplings.status': '已采样'
      # 'samplings.biochemistry': on
      'samplings.apps': '生化'
    commands.push '$project':
      barcode: 1
      profile: 1
      samplings: 1
      biochemistry: 1
      departments: 1
    commands.push '$unwind': '$departments'
    commands.push '$unwind': '$samplings'
    commands.push '$match':
      '$or': [
        'samplings.sampled.date_string': date
       ,
        'biochemistry.analyze_start.date_string': date
      ]
      'samplings.status': '已采样'
      'samplings.biochemistry': on
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
          name:    record.profile.name
          sex:     record.profile.sex
          age:     record.profile.age
          date:    date
          plate_hole: record.biochemistry?.disk_and_position?.trim()
          sample_date: record.sample_date
          status: record.departments.status
        result.push person if (person.date is date and person.status is '待检验' and '外检' not in record.profile.notes) or person.status in ['已上机未完成', '待审核', '已完成']
      callback null, result
