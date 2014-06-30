_ = require "underscore"

module.exports = (record_schema) ->

  record_schema.methods.adjust_departments_data = () ->
    
    # 只保留已完成和放弃的项目。
    # 如果有一个项目是已完成，则科室状态是已完成。
    for department in @departments
      found_complete_item = department.items.some (item) -> item.status is '已完成'
      department.status   = '已完成' if found_complete_item
      department.items    = department.items.filter((item) -> item.status in ['已完成', '放弃'])

    @departments = @departments.filter((department) -> department.items.length)
    
    # 若档案中存在心电图中的心电图项目和内科中的心律项目
    # 且心电图中有心房纤颤小结，心律中没有心房纤颤小结
    # 那么给心律项目添加心房纤颤小结
    # 内科的心律或者心电图出现`心房纤颤`症状，
    # 则内科中心率和心电图中都不会出`心动过速`和`心动过缓`
    electrocardiogram = _.find @departments, (d) ->
      d.name is '心电图'
    ecg_heart         = _.find electrocardiogram?.items, (i) ->
      i.name is '心电图'

    internal_medicine = _.find @departments, (d) ->
      d.name is '内科'
    internal_medicine_heart_rate = _.find internal_medicine?.items, (i) ->
      i.name is '心率' and i.status is '已完成'
    internal_medicine_heart_rhythm  = _.find internal_medicine?.items, (i) ->
      i.name is '心律' and i.status is '已完成'

    if ecg_heart and internal_medicine_heart_rhythm
      ecg_exists   = ecg_heart.conditions.some (c) ->
        c.name is '心房纤颤'
      heart_exists = internal_medicine_heart_rhythm.conditions.some (c) ->
        c.name is '心房纤颤'
      if ecg_exists and not heart_exists
        internal_medicine_heart_rhythm.conditions.push name: '心房纤颤'
        internal_medicine_heart_rhythm.normal = undefined
      if ecg_exists or heart_exists
        ecg_heart.conditions = ecg_heart.conditions.filter (c) ->
          c.name not in ['心动过速', '心动过缓']
        ecg_heart.normal = '未见明显异常' unless ecg_heart.conditions.length
        if internal_medicine_heart_rate
          internal_medicine_heart_rate.conditions = internal_medicine_heart_rate.conditions.filter (c) ->
            c.name not in ['心动过速', '心动过缓']
          internal_medicine_heart_rate.normal = '未见明显异常' unless internal_medicine_heart_rate.conditions.length
