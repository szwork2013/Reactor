# TODO: 如果程序中涉及常量依赖：
#   1. 减少常量依赖的篇幅（比如可以通过逆向查找的方式变型，不再使用常量方式叙述）
#   2. 将不能避免的相关叙述放在相同相近的地方，比如下面这部分与Schema关系更为密切。这些键也可以不重复撰写。
lis_departments = ['生化检验']

lis_event_keys =
  '生化检验': 'biochemistry'
  '血常规'  : 'hematology'
  '免疫检验': 'immunoassay'

moment = require "moment"
_      = require "underscore"

# TODO: module.parent.parent.exports.methods.sync_status = ->
# 降低对`index.coffee`的依赖；向左缩进一级。

module.exports = (record_schema) ->

  record_schema.methods.sync_status = ->

    samplings = @samplings

    # 第零步：全部采样标本名称
    sampling_names = samplings?.filter((sampling) -> sampling.status in ['已采样'])
    .map((sampling) -> sampling.name) or []

    date = moment().format('YYYY-MM-DD')
    
    # 第一步：设置项目状态
    for department in @departments
      department.items = department.items.filter (item) =>
        not item.sex or item.sex is @profile.sex

      sampled = (required_samplings = department.required_samplings).length and \
      required_samplings.every((sampling) -> sampling in sampling_names)
    
      for item in department.items
        if item.value? or item.normal or item.conditions.length
          item.status = '已完成'
        else if sampled
          item.status = '未完成'
        else if item.status is '未到场'
          item.status = '未完成'
        else if @images.some((image) -> image.tag?.match(item.name))
          item.status = '待检验'
        # 客人延期后改天再查（预约日期不是今天，到场日期为多个，最后一次到场日期为今天）
        # 将科室状态由延期变为未完成。
        else if @check_date isnt date and _.uniq(@appeared).length > 1 \
        and @appeared[@appeared.length - 1] is date and item.status is '延期'
          item.status = '未完成'
        else
          item.status or = '未完成'
   
    # 由于更换性别会出现删除科室项目，此时可能会出现无项目的科室，需要排掉
    @departments = @departments.filter((d) -> d.items.length)

    # 任意项目已完成，或者护士或医生为客人采集标本，该档案为非空档案。
    # TODO: 外检略有区别。外检全部采样不算数。
    # TODO: 整理要排除的样本
    special_samplings =[
      'HBV知情书'
      '基因检测口腔标本盒'
      '基因检测唾液标本盒'
      '便盒'
      '便管'
      '尿杯'
    ]
    @non_empty = @departments.some((department) -> department.items.some (item) -> item.status in ['已完成']) \
    or (samplings.some((sampling) -> sampling.status in ['已采样'] and sampling.name not in special_samplings)) \ # and '外检' not in @profile.notes) \
    or @images.filter((image) -> image.tag isnt '头像').length

    # non_empty档案不允许有未到场项目，为后续状态判定减少麻烦。
    # 例如，一个科室几个项目已完成，几个项目未到场。
    
    # 第二步：设置科室状态
    for department in @departments
      # TODO: A
      # department.status =
      #   if ...
      #      'xxx'
      #   else if ...
      #      'yyy'
      # TODO: B
      #   对科室仅一次遍历，第一步更新项目状态，第二步更新科室状态。
      if department.items.some((item) -> item.status is '延期')
        department.status = '延期'
      else if department.items.every((item) -> item.status is '未付费')
        department.status = '未付费'
      else if department.items.every((item) -> item.status is '放弃')
        department.status = '放弃'
      else if department.items.some((item) -> item.status in ['未完成', '待检验'])
        if department.required_samplings.length \
        and department.required_samplings.some((sampling) -> sampling in sampling_names)
          # TODO: 这个键名能否植入文档? @[department.lis_key] (这是一个getter就可以了)
          if @[lis_event_keys[department.name]]?.analyze_start?.date_string
            department.status = '已上机未完成'
          else
            department.status = '待检验'
        else if department.items.some((item) -> item.status is '待检验') # 放射科
          department.status = '待检验'
        else
          department.status = '未完成'
      # TODO: 仍然进一步使用OO设计，更为直接地叙述领域概念。
      else if not department.is_lis_department or @[lis_event_keys[department.name]].audit.user_id
        department.status = '已完成'
      else
        department.status = '待审核'
      if department.name is '生化检验'
        @biochemistry_status = department.status
        if department.status in ['未完成', '已上机未完成', '待检验', '待审核'] \
        and @biochemistry.audit.user_id
          @biochemistry.audit = undefined
      department.checking = undefined if department.status is '未完成'

    # 第四步：档案状态
    # 已完成、现场检查已完成、现场检查未完成、延期、未到场。
    departments = @departments.filter (d) => d.status isnt '未付费' and d.name not in @model('Record').ignore_departments()

    if @profile.age < 16
      departments = departments.filter (d) -> d.name isnt '骨密度'
    if not @non_empty
      @status = '未到场'
      @appeared = []
      @field_complete = undefined
      @report_complete = undefined
    else if @unfinished_departments.some((department) -> department.status is '未完成')
      @status = '检查中'
      @field_complete = undefined
      @report_complete = undefined
    else if departments.some((department) -> department.status is '延期')
      @status = '延期'
      @field_complete = undefined
      @report_complete = undefined
    else if departments.every((department) -> department.status in ['已完成', '放弃'])
      if not @paper_report or '仅由电子报告' in @profile.notes
        @status = '已发电子报告'
      else
        @status = if @printed_complete?.date_number then '已打印' else '已完成'
      @field_complete.date_number or = Date.now()
      @field_complete.date_string or = moment().format('YYYY-MM-DD')
      @report_complete.date_number or = Date.now()
      @report_complete.date_string or = moment().format('YYYY-MM-DD')
    else
      @status = '已离场'
      @field_complete.date_number or = Date.now()
      @field_complete.date_string or = moment().format('YYYY-MM-DD')
      @report_complete = undefined
    console.log 'Z', @status
