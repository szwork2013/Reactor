moment = require 'moment'

# 需求要求只支持自动适应中文,并且不强制更改
exports.dateFormat = (str) ->
  weekdays =
    '0': '周一'
    '1': '周二'
    '2': '周三'
    '3': '周四'
    '4': '周五'
    '5': '周六'
    '6': '周日'
  
  # 年份
  year = moment(str).year()
  # 今年年份
  this_year = moment().year()
  # 去年年份
  last_year = this_year - 1
  # 明年年份
  next_year = this_year + 1

  # 周格式化
  weekday = weekdays[moment(str).weekday()]
  
  # 今天
  this_date = moment().format('YYYY-MM-DD')
  # 昨天
  yesterday = moment().add('days',-1).format('YYYY-MM-DD')
  # 前天
  before_yesterday = moment().add('days',-2).format('YYYY-MM-DD')
  # 明天
  tomorrow = moment().add('days',1).format('YYYY-MM-DD')
  # 后天
  after_tomorrow = moment().add('days',2).format('YYYY-MM-DD')
  
  # 本周起始
  this_week_start = moment().startOf('week').format('YYYY-MM-DD')
  # 本周截止
  this_week_end = moment().endOf('week').format('YYYY-MM-DD')
  # 上周起始
  last_week_start = moment(this_week_start).subtract('days', 7).format('YYYY-MM-DD')
  # 上周截止
  last_week_end = moment(this_week_start).subtract('days', 1).format('YYYY-MM-DD')
  # 下周起始
  next_week_start = moment(this_week_end).add('days', 1).format('YYYY-MM-DD')
  # 下周截止
  next_week_end = moment(this_week_end).add('days', 7).format('YYYY-MM-DD')
  
  # 年月日
  year_month_date = moment(str).format('YYYY年M月D日')
  # 月日
  month_date      = moment(str).format('M月D日')


  #输出前天,昨天,今天,明天,后天
  if str is this_date
    '今天'
  else if str is yesterday
    '昨天' + ' ' + weekday
  else if str is before_yesterday
    '前天' + ' ' + weekday
  else if str is tomorrow
    '明天' + ' ' + weekday
  else if str is after_tomorrow
    '后天' + ' ' + weekday
  
  # 输出四年份　-　不是今年、去年、明年，则是四位年份
  else if year not in [this_year, last_year, next_year]
    year_month_date + ' ' + weekday
  # 输出去年
  else if year is last_year
    '去年' + month_date + ' ' + weekday
  # 输出明年
  else if year is next_year
    '明年' + month_date + ' ' + weekday
  
  # 输出周
  else if this_week_start <= str <= this_week_end
    '本' + weekday
  else if next_week_start <= str <= next_week_end
    '下' + weekday
  else if last_week_start <= str <= last_week_end
    '上' + weekday

  # 输出今年完整日期格式
  else
    moment(str).format('M月D日') + ' ' + weekday
