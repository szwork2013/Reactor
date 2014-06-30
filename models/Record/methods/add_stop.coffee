_ = require('underscore')

module.exports = (record_schema) ->
  
  non_repeating_regexps = [/心电图/]
  no_cookie_regexps = [/放射/, /采血/]

  # 推入一站检查信息规则为：
  record_schema.methods.add_stop = (stop) ->

    # 1. 起始时间与末站相同时（多科室并发诊断、采样后进行诊断），或为连续放射科影像时：
    #
    #   + 行为文字不同时（心电图采样诊断相同），增补行为文字，顿号分割；
    #
    # 2. /心电图/等支持会话的科室，如果开始时间不同（中间插入其它客人），不再更新服务结束时间，否则更新：
    #
    #   + 服务结束时间；
    #   + 服务结束日期；
    if (last_stop = _(@stops).last()) and \
    (stop.start is last_stop.start or no_cookie_regexps.some((regexp) -> regexp.test(last_stop.action) and regexp.test(stop.action)))
      last_stop.action += "、#{stop.action}" unless last_stop.action is stop.action
      # unless /心电图/.test(stop.action) and last_stop.start isnt stop.start
      last_stop.end = stop.end
      last_stop.date = stop.date
    else

      # 2. 以下行为不重复发生（重复推站时不做处理）：
      #
      #   + /心电图/（大客流时制图与诊断分开，不应出现多站心电图）。
      for regexp in non_repeating_regexps when regexp.test(stop.action)
        return if @stops.some(({action}) -> regexp.test(action))

      # 3. 其余情况，将该站推入末尾。
      @stops.push(stop)
