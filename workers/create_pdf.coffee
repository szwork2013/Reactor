{spawn, exec} = require 'child_process'
fairy         = require("fairy").connect()
queue         = fairy.queue "create_pdf"
models        = require "../models"
redis         = require "node-redis"
redis_client  = redis.createClient()

# 处理队列中的队列名称，生成pdf
# TODO: root_path = process.cwd()
queue.regist (nonsense, [subdomain, barcode], callback) ->
  models subdomain, (error, {Record}) ->
    console.log 'create_pdf', subdomain, barcode
    # callback()
    return callback error if error
    path_array = (__dirname).split('/')
    root_path = path_array.splice(0, 4).join('/')
    # TODO: string interpolation
    url = "http://#{subdomain}:5124/reports/"+barcode
    path = __dirname + '/../public/pdfs/reports/' + barcode + '.pdf'
    options =[
      url
      path
    ]
    # TODO: naming
    console.log __dirname + '/../utils'
    grep = exec 'osascript html2pdf3 ' + options.join(' '), {cwd: __dirname + '/../utils', timeout: 50000}, (err, stdout, stderr) ->
      if err
        grep.kill 'SIGKILL'
        console.log err, stderr, stdout
        return callback err
      Record.findOneAndUpdate {barcode: barcode}, {$set: {'pdf_created': on}}, {safe: on}, (error, record) ->
        return callback error if error
        callback()
