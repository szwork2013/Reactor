moment = require "moment"
_      = require "underscore"
redis  = require "node-redis"
redis_client = redis.createClient()

publish = (topic, send_data) ->
  #console.log topic, send_data
  redis_client.publish topic, JSON.stringify send_data

# 生化检验完成状态改变或者被触动了
module.exports = (record_schema) ->
  record_schema.pre 'save', (callback) ->
    # 当注册时没有此键
    @pre_departments_status or = {}
    @sync_status()
    # 
    {name, sex, age}  = @profile
    date = moment().format('YYYY-MM-DD')
    host = @model('Record').host?.toUpperCase()
    guest =
      barcode: @barcode
      name: name
      sex:  sex
      age:  age

    shenghua_department = _.find @departments, (d) -> d.name is '生化检验'
    before_status       = @pre_departments_status?['生化检验']
    after_status        = shenghua_department?.status
    sampling            = _.find @samplings, (s) -> s.tag is '生化'
    guest['date']       = sampling?.sampled?.date_string
    guest['plate_hole'] = @biochemistry?.disk_and_position?.trim()
    # 未到场、未付费、未完成 、待检验、已上机未完成、待审核、已完成
    #console.log before_status, after_status, after_department?.touched
    if (before_status isnt after_status and after_status is '待检验' and '外检' not in @profile.notes) \
    or (after_status isnt '待检验' and (before_status isnt after_status or shenghua_department?.touched))
      guest.status = after_status
      publish "#{host}:BIOCHEMISTRY_STATUS_CHANGE", [guest]
    
    radiology_department = _.find @departments, (d) -> d.name is '放射科'
    if radiology_department
      for item in radiology_department?.items
        if item.status is '待检验'
          #console.log host, item.name, @barcode
          redis_client.sadd "#{host}:放射学:#{item.name}:未诊断", @barcode
        else if item.status is '已完成'
          #console.log host, item.name, @barcode
          redis_client.srem "#{host}:放射学:#{item.name}:未诊断", @barcode
          # console.log @status
    callback()
