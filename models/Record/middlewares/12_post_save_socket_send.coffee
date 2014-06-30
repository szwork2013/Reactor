moment = require "moment"
_      = require "underscore"
redis  = require "node-redis"
redis_client = redis.createClient()

# 查看科室是否是已查
checked = (department) ->
  department.status in ['待检验', '已上机未完成', '待审核', '已完成', '放弃', '延期'] \
  or department.items.some((item) -> item.status is '已完成')

# 查看科室是否未查
unchecked = (status, department) ->
  (status is '未到场' and department.status in ['未付费', '未完成']) \
  or (status isnt '未到场' and department.status is '未完成')

publish = (topic, send_data) ->
  console.log topic, send_data
  redis_client.publish topic, JSON.stringify send_data

module.exports = (record_schema) ->
  record_schema.post 'save', (doc) ->
    if '外检' not in doc.profile.notes
      pre_departments_status = doc.pre_departments_status
      host = @model('Record').host.toUpperCase()
      {barcode, status, appeared, profile, doctor_check_time, departments} = doc
      record =
        barcode: barcode
        name: profile.name
        sex: profile.sex
        age: profile.age
        status: status
        check_date: profile.check_date
        unchecked: []
        checked: []
        doctor_check_time: doctor_check_time?.map((doctor) -> _id: doctor.finished.user_id, finished_date_number: doctor.finished.date_number)
      for department in departments
        record_ = _.clone record
        record_.dapartment   = department.name
        record_.wait_inspect = if department.status is '待检验' then on else off
        doctor_check_time2    = doctor_check_time?.filter((doctor) -> doctor.department_id is department._id.toString())
        record_.doctor_check_time = doctor_check_time2?.map (doctor) ->
          _id: doctor.finished.user_id, finished_date_number: doctor.finished.date_number
        if checked(department)
          record_.checked    = [department.name]
          record_.substandard = @model('Record').get_substandard_items department
        if unchecked(status, department)
          record_.unchecked  = [department.name]
        publish "#{host}:CHECK_SITUATIONS_CHANGE", {names: [department.name], transfer_data: [record_]}
      _departments = departments.filter((d) => d.name not in @model('Record').ignore_departments())
      record_ = _.clone record
      record_.unchecked = _departments.filter((department) -> unchecked(status, department)).map (d) -> d.name
      record_.checked   = _departments.filter((department) -> checked(department)).map (d) -> d.name
      publish "#{host}:CHECK_SITUATIONS_CHANGE", {names: ['体检中心'], transfer_data: [record_]}
      
      # 删除订单:以前有现在没有
      delete_names = []
      if pre_departments_status isnt {}
        for name of pre_departments_status
          if not departments.some((d) -> d.name is name)
            delete_names.push name
      for name in delete_names
        record_ = _.clone record
        record_.department = name
        record_.unchecked = []
        record_.checked   = []
        publish "#{host}:CHECK_SITUATIONS_CHANGE", {names: [name], transfer_data: [record_]}
