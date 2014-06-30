moment = require "moment"
_      = require "underscore"

module.exports = (record_schema) ->
  # 查看科室是否是已查
  checked = (department) ->
    department.status in ['待检验', '已上机未完成', '待审核', '已完成', '放弃', '延期'] \
    or department.items.some((item) -> item.status is '已完成')
  # 查看科室是否未查
  unchecked = (status, department) ->
    (status is '未到场' and department.status in ['未付费', '未完成']) \
    or (status isnt '未到场' and department.status is '未完成')

  record_schema.statics.CHECK_SITUATIONS_INIT = (str_departments, cb) ->
    console.log begin = (new Date).valueOf(), 'begin'
    if 'function' is typeof str_departments
      cb = str_departments
      str_departments = ''
    department_names = str_departments.split(',')
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
      name: '$profile.name'
      sex:  '$profile.sex'
      age:  '$profile.age'
      check_date: '$profile.check_date'
      doctor_check_time: '$doctor_check_time'
      status: 1
      'departments._id': 1
      'departments.name': 1
      'departments.status': 1
      'departments.items': 1
    @aggregate commands, (error, records) =>
      return callback error if error
      center = (new Date).valueOf()
      result = []
      for record in records
        {barcode, name, sex, age, status, appeared, check_date, departments, doctor_check_time} = record
        guest =
          barcode: barcode
          name: name
          sex: sex
          age: age
          status: status
          check_date: check_date
          unchecked: []
          checked: []
          doctor_check_time: doctor_check_time?.map((doctor) -> _id: doctor.finished.user_id, finished_date_number: doctor.finished.date_number)
        if str_departments is '体检中心'
          departments = departments.filter((d) => d.name not in @ignore_departments())
          checked_departments   = departments.filter (department) -> checked(department)
          unchecked_departments = departments.filter (department) -> unchecked(status, department)
          guest_ = _.clone guest
          guest_.unchecked = unchecked_departments.map (d) -> d.name
          guest_.checked   = checked_departments.map (d) -> d.name
          result.push guest_ if guest_.unchecked.length or guest_.checked.length
        else
          departments = departments.filter((d) -> d.name in department_names)
          for department in departments
            guest_ = _.clone guest
            guest_.dapartment   = department.name
            guest_.wait_inspect = if department.status is '待检验' then on else off
            doctor_check_time2   = doctor_check_time?.filter((doctor) -> doctor.department_id is department._id?.toString())
            guest_.doctor_check_time = doctor_check_time2?.map (doctor) ->
              _id: doctor.finished.user_id, finished_date_number: doctor.finished.date_number
            if checked(department)
              guest_.checked    = [department.name]
              guest_.substandard = @get_substandard_items department
            if unchecked(status, department)
              guest_.unchecked  = [department.name]
            result.push guest_ if guest_.unchecked.length or guest_.checked.length
      end = (new Date).valueOf()
      console.log end - begin
      cb null, result
