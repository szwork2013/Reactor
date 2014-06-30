# sms_marketing?mobile=true&suggestions={suggestions}&from={from}&to={to}
_  = require "underscore"
async = require "async"

app.get '/sms_review_notice', (req, res) ->
  {Record} = req.models
  commands = []
  commands.push
    '$match':
      'profile.tel':
        '$nin': ['', null]
      'sms_review_notice':
        '$ne': on
      'suggestions':
        '$ne': []
  commands.push
    '$project':
      'tel': '$profile.tel'
      'name': '$profile.name'
  commands.push
    '$sort':
      'barcode': 1
  Record.aggregate commands, (error, records) ->
    return res.send 500, error.stack if error
    records = records.filter((record) -> not record.name.match(/测试/) and record.tel?.length is 11)
    tels = _.uniq records.map((record) -> record.tel)
    console.log tels.length
    #tels = ['13811398975','18618462829', '13810917067', '15811284008']
    tasks = tels.map (tel) -> (callback) ->
      Record.send_sms_review_notice tel, (error, msg) ->
        return callback error if error
        if msg.split('|')[0] is '1'
          msg="ok"
        else if msg isnt '无症状'
          msg="[号码：#{tel}发送失败，状态：#{msg}]"
        callback null, msg
    async.parallelLimit tasks, 5, (error, messages) ->
      return res.send error if error
      sendArr =
        success : []
        error : []
      for idx in messages
        if idx is 'ok'
          sendArr.success.push idx
        else
          sendArr.error.push idx
      str = "发送成功#{sendArr.success.length}个"
      str += "发送失败#{sendArr.error.length}个，#{sendArr.error}"
      res.send message: str
