_          = require "underscore"
superagent = require 'superagent'
moment     = require 'moment'

module.exports = (record_schema) ->
  record_schema.statics.send_sms_review_notice = (tel, cb) ->
    #@find({'profile.tel': tel, barcode: {'$in':['10015408','10003255','10000748', '10019726']}})
    @find({'profile.tel': tel, sms_review_notice: {'$ne': on}})
    .select('profile.name profile.sex profile.check_date')
    .select('suggestions.conditions.name suggestions.combos')
    .exec (error, records) =>
      return cb error if error
      return cb null, '已发送或无此号码'  unless records.length
      records = records.sort (a, b) ->
        if a.profile.check_date < b.profile.check_date then 1 else -1
      record  = records[0]
      combos  = _.flatten((_.pluck record.suggestions, 'combos').filter (item) -> item)
      return cb null, '无症状' unless combos.length
      record.suggestions = record.suggestions.filter (s) -> s.combos.length
      conditions = _.pluck  _.flatten((_.pluck record.suggestions, 'conditions').filter (item) -> item ), 'name'
      sendStr =  "#{record.profile.name}" + (if "#{record.profile.sex}" is '男' then '先生' else '女士')
      sendStr += "您好！#{moment(record.profile.check_date).month()+1}月份体检检出：#{conditions.join('，')}。"
      sendStr += "为了您的身体健康，请致电您的健康顾问（010-82626102），为您定制复查方案。［瀚思维康］"
      superagent
      .get('http://pi.noc.cn/SendSMS.aspx')
      .send("Msisdn=#{tel}&SMSContent=#{sendStr}&SGType=5&ECECCID=100316&Password=zkwk888")
      .end (retMsg) =>
        if retMsg.ok
          @model('Record').mark_sms_review_notice tel, (error, record) ->
            return cb error if error
            cb null, retMsg.text
        else
          cb null, reMsg.body
