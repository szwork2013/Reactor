fairy      = require('fairy').connect()
queue      = fairy.queue 'summarization'
_          = require "underscore"
mongoose   = require "mongoose"
models     = require "../models"
redis      = require "node-redis"
redis_client = redis.createClient()

queue.regist ([subdomain, barcode], callback) ->
  console.log subdomain, barcode, 'summarize: subdomain,barcode'
  models subdomain, (error, {Record, Department, SuggestionGroup}, settings) ->
    console.log error if error
    return callback error if error
    begin = (new Date).valueOf()
    console.log "A"
    do summarize = =>
      Record.barcode barcode, {paid_all: on}, (error, record) ->
        # console.log "SUMMARIZATION:0", (new Date).valueOf() - begin
        # console.log barcode, error if error
        console.log error if error
        return callback error if error
        console.log "B"
        return callback() unless record
        console.log "C"
        # 重新设置生成pdf键
        record.pdf_created = undefined
        {cached_departments_orders, cached_items_orders, cached_detail_expstr_hash, cached_unchecked_items} = Department
        # 科室排序
        record.departments = record.departments.sort (a, b) ->
          if cached_departments_orders?[a._id] > cached_departments_orders?[b._id] then 1 else -1
        # 项目排序
        # for department in record.departments
        #   department.items = department.items.sort (a, b) ->
        #     if cached_items_orders?[a._id] > cached_items_orders?[b._id] then 1 else -1

        # 特殊情况新增小结
        # TODO: 根据科室调整，调整相应代码。
        # TODO: 为健康档案模型实现`find_item('外科/前列腺')`方法。
        ultrasound = _.find record.departments, (d) -> d.name is '小器官彩超'
        surgery    = _.find record.departments, (d) -> d.name is '外科'
        ultrasound_prostate = _.find ultrasound?.items, (i) -> i.name is '前列腺' and not i.note
        surgery_prostate = _.find surgery?.items, (i) -> i.name is '肛诊' and not i.note
        if ultrasound_prostate and surgery_prostate
          # 若超声中没有列腺轻度增大或前列腺增大增生小结
          # 外科中出了前列腺轻度增生，超声中需要出前列腺轻度增大
          # 外科中出了前列腺中度增生或前列腺重度增生，
          # 超声中需要出前列腺增大增生
          not_exists = ultrasound_prostate.conditions.every (cond) ->
            cond.name not in ['前列腺轻度增大', '前列腺增大增生']
          if not_exists
            if surgery_prostate.conditions.some((c) -> c.name is '前列腺轻度增生')
              # 给项目新增小结，要清除正常情况
              ultrasound_prostate.normal = undefined
              ultrasound_prostate.conditions.push name: '前列腺轻度增大'
            else if surgery_prostate.conditions.some((c) -> c.name in ['前列腺中度增生', '前列腺重度增生'])
              ultrasound_prostate.normal = undefined
              ultrasound_prostate.conditions.push name: '前列腺增大增生'

        departments = record.departments.toObject()
        conditions_array = []
        record_checked_items = []
        # record.departments_status.filter((d) -> d.status isnt '放弃')
        # .forEach (d) -> record_checked_items.push d.name
        # console.log "SUMMARIZATION:1", (new Date).valueOf() - begin
        unmatch_detail = off
        for department in departments
          for item in department.items
            if item.name.match(/乙肝/)
              continue unless record.hbv_agreement_signed
            # 便于获取未查项目
            record_checked_items.push(item.name) unless item.note
            # 给症状添加项目正常，便于汇总建议
            conditions_array.push({name: item.name + '正常'}) if item.normal
            for condition in item.conditions
              # 如果有detail，需要判定detail是否匹配该症状的表达式。每个症状语法，1比1对应一个正则表达式。
              if condition.detail? and not unmatch_detail
                unmatch_detail = on unless condition?.detail.match(new RegExp(cached_detail_expstr_hash[condition.name]))
              if condition.name in ['偏高', '偏低', '阳性', '阴性', '弱阳性']
                # 这里summary是易混淆的症状真实名称，今后修改键名
                condition.name = item.name + condition.name
                # console.log condition.name
              condition.name = condition.summary or condition.name
              conditions_array.push condition
        record.inspection_mode = if unmatch_detail then '人工' else '自动'
        unchecked_items = cached_unchecked_items.filter (item) -> item not in record_checked_items
        # 给症状添加未查症状，便于汇总建议
        unchecked_items.forEach (item) ->
          conditions_array.push({name: item + '未查'})
          # console.log "SUMMARIZATION:2", (new Date).valueOf() - begin
        suggestions_hash = SuggestionGroup.cached_suggestions_hash #  JSON.parse JSON.stringify SuggestionGroup.cached_suggestions_hash
        # console.log "SUMMARIZATION:2.5", (new Date).valueOf() - begin

        condition.suggestions = suggestions_hash[condition.name] for condition in conditions_array
        total_suggestions = _.union ((_.pluck conditions_array, 'suggestions').filter (s) -> s)...
        stable_conditions_hash = {}
        volatile_conditions_hash = {}
        for condition in conditions_array
          stable_conditions_hash[condition.name] = condition
          volatile_conditions_hash[condition.name] = condition
        # console.log volatile_conditions_hash
        {sex, age} = record.profile
        record.suggestions = []
        # console.log "SUMMARIZATION:3", (new Date).valueOf() - begin
        # console.log volatile_conditions_hash['高血压，药物控制不理想']
        for suggestion in total_suggestions
          conditions = suggestion.conditions
          if (conditions.every (condition) -> volatile_conditions_hash[condition.name])
            suggestion = JSON.parse JSON.stringify suggestion
            # console.log suggestion
            suggestion.content =
              SuggestionGroup.tweak_content suggestion.content, sex, age, stable_conditions_hash
            for condition in suggestion.conditions
              if volatile_conditions_hash[condition.name]?.detail
                condition.detail = volatile_conditions_hash[condition.name].detail
              # console.log condition.name
              # console.log "A", condition.name
              delete volatile_conditions_hash[condition.name] unless condition.repeatable
              # console.log "B", condition.name
            # BUG
            console.log suggestion.combos, 'combos'
            suggestion.conditions = [suggestion.summary] if suggestion.summary
            # console.log suggestion
            record.suggestions.push suggestion
            # console.log "SUMMARIZATION:4", (new Date).valueOf() - begin
        #record.suggestions = record.suggestions.sort (a, b) ->
          #if a.importance > b.importance then 1 else -1
        suggestions_a = record.suggestions.filter (s) -> s.importance is 'A'
        
        suggestions_b = record.suggestions.filter (s) -> s.importance isnt 'A'
        record.suggestions = undefined
        record.suggestions = [suggestions_a..., suggestions_b...]
        record.summarize   = on
        # console.log "SUMMARIZATION:5", (new Date).valueOf() - begin
        record.save (error, record) ->
          console.log 'wangling end'
          console.log error if error
          return summarize() if error instanceof mongoose.Error.VersionError
          return callback error if error
          # console.log "SUMMARIZATION:FINISHED", (new Date).valueOf() - begin
          # 自动总检生成pdf
          console.log "ENQUEUE CREATE PDF", JSON.stringify([subdomain, record.barcode]), [subdomain, record.barcode]
          fairy.queue('create_pdf').enqueue JSON.stringify([subdomain, record.barcode]), [subdomain, record.barcode] #unless unmatch_detail
          callback()
