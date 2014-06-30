mongoose   = require 'mongoose'
superagent = require 'superagent'
fs         = require 'fs'
async      = require 'async'
event_emitter = new (require('events').EventEmitter)
#mongoose.set 'debug', on

models_cache = {}

module.exports = (host, callback) ->
  return callback null, models if models = models_cache[host]
  event_emitter.on host, (models) ->
    callback null, models
  event_emitter.setMaxListeners(0)
  return if event_emitter.listeners(host).length > 1
  
  # TODO: 这个callback有可能被callback多次么?
  superagent
  .get("midgar.healskare.com:3000/reactors/#{host}/mongodb")
  .end ({body: {host: db_host, name: db_name, port: db_port}, error}) ->
    return callback '该健检中心尚未登记' if error
    # console.log "A", db_host, db_name, db_port
    fs.readdir __dirname, (err, files) ->
      console.log "B", db_host, db_name, db_port
      # TODO: 使用Spec描述多家健检中心的行为。
      connection = mongoose.createConnection db_host, db_name, db_port

      models = files.reduce (models, file) ->
        return models unless fs.statSync("#{__dirname}/#{file}").isDirectory()
        return models if file is 'Shared'
        console.log 'FILE', file
        model = connection.model file, require "./#{file}/index.coffee"
        model.host = host
        models[file] = model
        models
      , {}

      # console.log key for key, model of models when model.cache
      tasks = (model.cache.bind model for key, model of models when model.cache) #and key isnt 'SuggestionGroup')
      # console.log "CALLBACK A"
      # return event_emitter.emit host, models_cache[host] = models
      async.parallel tasks, (error) ->
        console.log "CALLBACK B", error
        # console.log error, 'error'
        return callback error if error
        event_emitter.emit host, models_cache[host] = models
