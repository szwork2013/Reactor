_  = require "underscore"
superagent = require 'superagent'

module.exports = (record_schema) ->
  record_schema.statics.send_sms = (tel, profile, cb) ->
    if 'function' is typeof profile
      cb = profile
      profile = {}
    return cb() unless tel
    @find({'profile.tel': tel})
    .select('profile.name profile.hash_id profile.check_date')
    .exec (error, records) =>
      return cb error if error
      return cb null, '无此号码'  unless records.length
      records = records.sort (a, b) ->
        if a.profile.check_date < b.profile.check_date then 1 else -1
      groups = _.groupBy records, (record) -> record.profile.name
      results = for name, records of groups
        name: records[0].profile.name, hash_id: records[0].profile.hash_id
      sendStr="您的登陆信息：\n"
      if profile.name
        sendStr += "姓名：#{profile.name}\n验证码：#{profile.hash_id}\n"
      else
        for {name,hash_id} in results
          sendStr += "姓名：#{name}\n验证码：#{hash_id}\n"
      sendStr += "查看报告请登录 wedocare.com，如有疑问请联系客服010-62659812 【瀚思维康】"
      sendTel = tel
      superagent
      .get('http://pi.noc.cn/SendSMS.aspx')
      .send("Msisdn=#{sendTel}&SMSContent=#{sendStr}&SGType=5&ECECCID=100316&Password=zkwk888")
      .end (retMsg) =>
        if retMsg.ok
          @model('Record').mark_sms_sent tel, (error, record) ->
            return cb error if error
            cb null, retMsg.text
        else
          cb null, reMsg.body
