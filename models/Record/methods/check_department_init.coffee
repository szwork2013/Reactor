_      = require "underscore"
moment = require "moment"

module.exports = (record_schema) ->

  record_schema.statics.DEPARTMENT = () ->
    if arguments.length is 2 and 'function' is typeof arguments[1]
      department_name = arguments[0]
      callback = arguments[1]
    else
      return callback new Error "参数不正确"
    date = moment().format('YYYY-MM-DD')
    commands = []
    commands.push '$match':
      '$or': [
        'appeared': date
      ,
        'profile.check_date': date
      ]
      'profile.notes': '$nin': ['外检']
    commands.push '$project':
      barcode: 1
      appeared: 1
      profile: 1
      'departments.name': 1
      'departments.status': 1
      'departments.checking.finished': 1
    commands.push '$unwind': '$departments'
    commands.push '$match':
      'departments.name': department_name
      '$or': [
        'departments.checking.finished.date_string': '$exists': off
      ,
        'departments.checking.finished.date_string': date
      ]
    @aggregate commands, (error, records) ->
      return callback error if error
      result =
        department: department_name
        records: []
      for record in records
        guest =
          barcode: record.barcode
          name:    record.profile.name
          sex:     record.profile.sex
          age:     record.profile.age
          source:  record.profile.source
          status:  record.departments.status
        result.records.push guest
      console.log result, 'result'
      callback null, result
