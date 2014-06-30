###
Module dependencies.
###
express    = require "express"
http       = require "http"
global.app = app = express()
RedisStore = require('connect-redis')(express)
models     = require "./models"
_          = require "underscore"
mongoose   = require "mongoose"
ObjectId   = mongoose.Types.ObjectId
{no_cache} = require './utils/util.coffee'
superagent = require 'superagent'
browserClient = require('browser-client')
#cme = require './wechat_modules/cme'
#detail = require './wechat_modules/detail'
detail = require '../cme/detail'
cme = require '../cme/cme'

#解决www域名重定向方法
app.use (req, res, next) ->
  return res.send 400 unless req.host?
  console.log req.ip
  return if req.ip is '122.143.1.16'
  return res.redirect "#{req.protocol}://#{match[1]}#{req.url}" if match = req.host.match /^www\.(.*)/i
  next()

app.use browserClient()
#输出客户访问信息
app.use (req, res, next) ->
  console.log "内核：safari 版本：#{req.browserClient.version}" if req.browserClient.safari
  console.log "内核：firefox 版本：#{req.browserClient.version}" if req.browserClient.firefox
  console.log "内核：chrome 版本：#{req.browserClient.version}" if req.browserClient.chrome
  console.log "内核：opera 版本：#{req.browserClient.version}" if req.browserClient.opera
  console.log "内核：ie 版本：#{req.browserClient.version}" if req.browserClient.ie
  next()

app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.compress()
  app.use express.bodyParser {limit: '50mb'}
  app.use express.cookieParser()
  #app.use express.favicon()
  app.use express.logger("dev")
  app.use express.methodOverride()
  app.use no_cache

app.use express.session
  secret: 'my keyboard cat'
  store: new RedisStore
  cookie: {maxAge: 1000 * 60 * 60 * 24 * 30}

# 根据请求域名得到Mongoose模型。
app.use (req, res, next) ->
  models req.host, (err, models) ->
    return res.send 400, err.stack if err
    req.models = models
    next()

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', 'http://localhost:63019'
  #res.header 'Access-Control-Allow-Origin', 'http://localhost:34355'
  res.header 'Access-Control-Allow-Methods', '*'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, *'
  res.header 'Access-Control-Allow-Credentials', 'true'
  if req.method is 'OPTIONS'
    return res.send 204
  next()

app.use app.router
app.use express.static(__dirname + "/web")

app.configure "development", ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  return res.render "web_error" if req.browserClient.ie and req.browserClient.version < 8.0
  res.render 'index', records: req.session?.records or []

app.get '/logout', (req, res) ->
  req.session.destroy()
  res.redirect '/'

app.get '/reports/:filename', (req, res) ->
  console.log req.session, 'req.session'
  console.log guest_barcodes = req.session?.guest_barcodes
  return res.redirect "#{req.protocol}://#{req.host}" if !req.session.guest_barcodes?
  datas = req.params.filename.split('_')
  date  = datas[1]
  date  = date.substr(0,4) + '-' + date.substr(4,2) + '-' + date.substr(6,2)
  res.sendfile('./public/pdfs/reports/' + guest_barcodes[date] + '.pdf')

app.options '/guest_login', (req, res) ->
  res.send 200

app.post '/guest_login', (req, res) ->
  console.log req.body
  req.models.Record.guest_login req.body, (error, records) ->
    return res.send 400, error.stack if error
    return res.send 403, "登录失败，您输入的用户名或密码错误！" unless records.length
    guest_barcodes = records.reduce (memo, record) ->
      memo[record.profile.check_date] = record.barcode
      memo
    , {}
    req.session.records = records
    req.session.guest_barcodes = guest_barcodes
    res.send records

app.post '/batches/:batch/send_sms', (req, res) ->
  req.models.Batch.send_sms req.params.batch, (error, messages) ->
    return res.send 500, error.stack if error
    sendArr =
      success : []
      error : []
    #console.log messages
    for idx in messages
      if idx is 'ok'
        sendArr.success.push idx
      else
        sendArr.error.push idx
    console.log "发送成功#{sendArr.success.length}个"
    console.log "发送失败#{sendArr.error.length}个，#{sendArr.error}"
    res.send messages

app.post '/send_sms', (req, res) ->
  console.log req.body.tel, 'tel'
  req.models.Record.send_sms req.body.tel, (error, message) ->
    return res.send 500, error.stack if error
    res.send message

  #req.models.Record.get_name_hashids_by_tel req.body.tel, (error, results) ->
  #  return res.send 500, error.stack if error
  #  return res.send {error:-1}  if results.length is 0

  #  sendStr="您的登陆信息：\n"
  #  for {name,hash_id} in results
  #    sendStr += "姓名：#{name}\n验证码：#{hash_id}\n"
  #  sendStr += "查看报告请登录 wedocare.com，如有疑问请联系客服010-62659812 【瀚思维康】"
  #  
  #  sendTel = req.body.tel
  #  superagent
  #  .get('http://pi.noc.cn/SendSMS.aspx')
  #  .send("Msisdn=#{sendTel}&SMSContent=#{sendStr}&SGType=5&ECECCID=100316&Password=zkwk888")
  #  .end (retMsg) ->
  #    if retMsg.ok
  #      return res.send retMsg.body
  #    else
  #      return res.send retMsg.text

        #app.post '/send_group_sms', (req, res) ->
  #for person in req.body
    # person[]

app.get '/batches/:batch/divisions', (req, res) ->
  {batch} = req.params
  batch = if batch.match /[0-9a-f]{24}/ then ObjectId(batch)
  else batch
  return res.send [] if batch is 'undefined'
  commands = []
  commands.push $match:
    'profile.batch': batch
  commands.push $group:
    _id: '$profile.division'
  req.models.Record.aggregate commands, (error, results) ->
    return res.send 500, error.stack if error
    divisions = (_.pluck results, '_id').filter (item) -> item
    divisions.push '其他' if '其他' not in divisions
    res.send divisions

app.get '/batches/:name/package', (req, res) ->
  {Batch, Product} = req.models
  Batch.find(company: req.params.name)
  .select('registration.date_number _id')
  .sort('-registration.date_number')
  .exec (error, batches) ->
    return res.send 500, error.stack if error
    return res.send 404 unless batches.length
    Product.findOne({batch: batches[0]._id})
    .exec (error, product) ->
      return res.send 500, error.stack if error
      res.send product

#  * `req.body`内容分别如下：
#    {
#      _id: "5e5bb37258200ed9aabc8d04", 
#      name: '北京九强生物技术股份有限公司(女宾)', 
#      category: 'package',
#      paid: 2,
#      price: 300
#    }
app.post '/records/:barcode/orders', (req, res) ->
  req.models.Record.findOne(barcode: req.params.barcode).exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 400 unless record
    record.add_order req.body, (error) ->
      return res.send 500, error.stack if error
      record.save (error) ->
        return res.send 500, error.stack if error
        res.send {}

#  * `req.body`内容分别如下：
#    {
#      "profile": {
#        name:'王玲',
#        sex:'female',
#        age:25,
#        id: '421023198806030445',
#        check_date: '2013-08-09'
#        check_time: 'A'
#        tel: '13811237854'
#        notes: ['员工编号：12345']
#        batch: '4e5bb37258200ed9aabc5d11',
#        division:'研发部',
#        source: '北京九强生物技术股份有限公司'
#        }
#      }
app.post '/records', (req, res) ->
  #req.body.registration =
  # staff: req.event
  req.body._id = new ObjectId
  record = new req.models.Record req.body
  record.save (error, record) ->
    return res.send 500, error.stack if error
    res.send barcode: record.barcode

# 4 wechat
app.post '/wechat', cme
app.get '/cme/:ic_code/:year', detail.get_score

http.createServer(app).listen 80, () ->
  console.log "Express server listening on port 80 "
