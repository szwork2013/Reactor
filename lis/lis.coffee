# ## 设备接驳
#
# 每个反应堆服务`M`家健检中心，除该`M`家健检中心`Windows Store App`以外，
# 还负责该`M`家健检中心设备通信。部分设备通信机制是反应堆主动发起的，故：
# 每个反应堆需要知晓其负责健检中心列表。
#
# 列表服务位于`http://midgar.healskare.com:3000/lis`，根据反应堆`IP`地址，
# 返回该反应堆需要负责健检中心列表，列表项为该健检中心二级域名，如：
#
#   + `healthcare_center_001.healskare.com`
#   + `healthcare_center_002.healskare.com`
#   + `healthcare_center_003.healskare.com`
# 

fs          = require "fs"
mongoose    = require "mongoose"
superagent  = require "superagent"
models      = require "../models"
mongoose.set 'debug', on
redis = require 'node-redis'
redis_client = redis.createClient()

global.app =
  publish: (topic, message) ->
    redis_client.publish topic, JSON.stringify message

superagent.get("http://midgar.healskare.com:3000/lis")
.end ({body: domains}) ->
  console.log domains
  # TODO: www.baidu.com中，subdomain是www。
  for subdomain in domains
    do (subdomain) ->
      superagent.get("http://midgar.healskare.com:3000/reactors/#{subdomain}/lis")
      .end ({body: {biochem, bcm}}) ->
        models subdomain, (error, models, settings) ->
          return console.error error if error
          console.log models.Record.host
          require('./biochem.coffee')(models, biochem)
          require('./hematology.coffee')(models, bcm)
