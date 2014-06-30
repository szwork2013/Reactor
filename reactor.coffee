cluster = require 'cluster'
numCPUs = require('os').cpus().length
{spawn} = require 'child_process'
redis        = require "node-redis"
redis_client = redis.createClient()


if cluster.isMaster
  console.log 'in master cluster process'
  for i in [0...numCPUs]
    cluster.fork()
  cluster.on 'exit', (worker) ->
    console.log 'worker ' + worker.process.pid + ' died. restart...'
    cluster.fork()

else
  ###
  Module dependencies.
  ###
  moment     = require "moment"
  moment.__defineGetter__ 'today', -> @().format('YYYY-MM-DD')
  crypto     = require "crypto"
  express    = require "express"
  global.app = app = express()
  RedisStore = require('connect-redis')(express)
  {exec}     = require "child_process"
  http       = require "http"
  request    = require "superagent"
  path       = require "path"
  models     = require "./models"
  _          = require "underscore"
  redis        = require "node-redis"
  redis_client = redis.createClient()
  {no_cache, authorize} = require './utils/util.coffee'
  WebSocketServer = require('ws').Server
  # require('look').start()
  crypto_password  = 'MySecretKey123'
  fairy            = require('fairy').connect()
  global.authorize = authorize
  global.fairy     = fairy

  app.configure ->
    app.set "port", process.env.PORT or 5124
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.favicon()
    app.use express.logger("dev")
    app.use express.compress()
    app.use express.methodOverride()
    app.use express.bodyParser() #{limit: '50mb'}
    app.use express.cookieParser()
    app.use no_cache
    app.use require('fairy/web').connect().middleware
    app.use express.static(path.join(__dirname, "public"))

  app.publish = (topic, send_data) ->
    # console.log topic, send_data
    redis_client.publish topic, JSON.stringify send_data

  request.get("http://midgar.healskare.com:3000/whoami")
  .query({type: "reactor"})
  .end ({body: {redis: {host, port}}}) ->

    # console.log host, port
    app.use express.session
      secret: 'keyboard cat'
      store: new RedisStore {host: host, port: port}
      cookie: {maxAge: 1000 * 60 * 60 * 24 * 30}

    app.use (req, res, next) ->
      req.session.stops ?= {}
      next()
    # app.use app.router

    app.use (req, res, next) ->
      req.user = req.session?.user or null
      # console.log 'SESSION', req.session
      # console.log 'USER', req.session?.user
      # console.log 'USER2', req.user
      req.__defineGetter__ 'event', ->
         # console.log 'event', req is @
         # console.log 'event2', @user
         # console.log 'event3', req.user
         user_id: @user?._id
         user_name: @user?.name
         date_number: Date.now()
         date_string: moment().format('YYYY-MM-DD')
         #  _.extend (@user or {}),
         #   user_id: @user?._id
         #   user_name: @user?.name
         #   date_number: Date.now()
         #   date_string: moment().format('YYYY-MM-DD')
      next()

    # 根据请求域名得到Mongoose模型。
    app.use (req, res, next) ->
      models req.host, (err, models, settings) ->
        return res.send 400, err.stack if err
        req.models = models
        req.settings = settings
        next()

    app.configure "development", ->
      app.use express.errorHandler()


    require './routes'

    app.get "/", (req, res) ->
      console.log req.get('host')
      res.render 'index1', {title: 'Express'}

    app.get '/dmy', (req, res) ->
      res.render 'mianyi_download', {layout: false}

    app.get '/unfinished', (req, res) ->
      res.render 'unfinished', {layout: false}

    app.get '/xray', (req, res) ->
      res.render 'xray', {layout: false}

    app.get "/complete", (req, res) ->
      res.render 'complete'
       
    app.post '/authentication', (req, res) ->
      req.models.User.authenticate req.body, (error, user) ->
        return res.send 400, error.stack if error
        return res.send 403, "失败" unless user
        return res.send 403, "权限" if req.query.app?.toLowerCase() not in (user.apps.map (app) -> app.toLowerCase())
        return res.send 403, "版本" if 1 > 2
        req.session?.user = user
        req.session.stops ?= {}
        delete req.session.barcode
        # console.log 'req.session.user', user
        room   = "#{user.name}@#{req.host}"
        cipher = crypto.createCipher 'aes192', crypto_password
        credential = cipher.update room, 'utf8', 'hex'
        credential += cipher.final 'hex'
        data =
          credential: credential
          _id: user._id
          name: user.name
          roles: user.roles
          radiology_diagnosis_parts: user.radiology_diagnosis_parts
          required_peripherals: []
          trust: 0.9
        if user.name isnt 'demo'
          if req.query.app is '早餐' and '早餐' in user.roles
            data.required_peripherals = ['条码打印机']
          if req.query.app in ['前台']
            if '护士' in user.roles
              data.required_peripherals = ['证件阅读器', '条码打印机', '激光打印机']
            else if '客服' in user.roles
              data.required_peripherals = ['电话']
          if req.query.app is '运营' and '护士' in user.roles
            data.required_peripherals = ['激光打印机']
          if req.query.app is '收银' and '收银' in user.roles
            data.required_peripherals = ['票据打印机外设']
        if user.name in ['demo']
          if req.query.app in ['前台']
            data.tel_not_required = on
        res.send data

    server = http.createServer(app)
    server.listen app.get("port"), ->
      console.log "Express server listening on port " + app.get("port")
    
    process.setMaxListeners(0)

    global.websockets = websockets =
      'CHECK_SITUATIONS_INIT': []
      'BIOCHEMISTRY_STATUS_INIT': []
      'NEW_BIOCHEMISTRY_STATUS_INIT': []

    wss = new WebSocketServer({port: 8080})

    date = ''
    wss.on 'connection', (ws) ->
      console.log 'websocket connected'
      host = ws.upgradeReq.headers.host.split(':')[0]
      ws.host = host.toUpperCase()
      redis_client.subscribe "#{ws.host}:CHECK_SITUATIONS_CHANGE"
      redis_client.subscribe "#{ws.host}:BIOCHEMISTRY_STATUS_CHANGE"
      redis_client.subscribe "#{ws.host}:NEW_BIOCHEMISTRY_STATUS_CHANGE"
      ws.on 'message', (message) =>
        messages = message.split(':')
        ws.page_source = messages[1]
        if messages[1] is 'CHECK_SITUATIONS_INIT'
          ws.departments = messages[2].split(',')
        websockets[ws.page_source]?.push ws
        models host, (error, models) =>
          console.log host, error if error
          {Record, Batch} = models
          params = message.split(':').splice(2)
          date   = params[0]
          callback = (error, data) ->
            return ws.send error if error
            data.init = on
            # console.log 'init', data
            ws.send JSON.stringify data
          params.push callback
          if Record?[messages?[1]]
            console.log 'static:', messages?[1]
            Record[messages?[1]] params...
      ws.on 'close', () ->
        if websockets[ws.page_source]
          websockets[ws.page_source] = (x for x in websockets[ws.page_source] when x isnt ws)
        console.log 'stopping client interval'

    redis_client.on "message", (channel, message) ->
      message = JSON.parse('' + message)
      channels = channel.split ':'
      host = channels[0]
      topic = channels[1]
      department = channels?[2]
      # console.log 'message_topic', topic
      topic_to_socket =
        'BIOCHEMISTRY_STATUS_CHANGE':     'BIOCHEMISTRY_STATUS_INIT'
        'CHECK_SITUATIONS_CHANGE':        'CHECK_SITUATIONS_INIT'
        'NEW_BIOCHEMISTRY_STATUS_CHANGE': 'NEW_BIOCHEMISTRY_STATUS_INIT'
      if topic is 'BIOCHEMISTRY_STATUS_CHANGE' and date is message?[0]?.date
        for websocket in websockets[topic_to_socket[topic]] or [] when websocket.host is host
          websocket.send JSON.stringify message
      else if topic is 'NEW_BIOCHEMISTRY_STATUS_CHANGE'
        for websocket in websockets[topic_to_socket[topic]] or [] when websocket.host is host
          websocket.send JSON.stringify message
      else if topic is 'CHECK_SITUATIONS_CHANGE'
        for websocket in websockets[topic_to_socket[topic]] or [] when websocket.host is host
          if websocket.departments.join().match(message.names[0])
            websocket.send JSON.stringify message.transfer_data
