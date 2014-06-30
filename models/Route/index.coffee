mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
_        = require "underscore"
redis    = require "node-redis"
redis_client = redis.createClient()
redis_client.subscribe "touch_route"

department_schema =
  # 科室编号
  _id: String
  # 房间编号
  door_number: String
  # 房间名称
  door_name: String

department_schema = new Schema department_schema, {versionKey: false}

route_schema =
  # 
  _id: ObjectId
  # 性别
  sex: {type: String, enum: ['男', '女']}
  # 年龄下限
  age_lt: Number
  # 年龄上限
  age_ut: Number
  # 是否合并 
  is_merged: Boolean
  # 路线顺序 TODO: 人可以看明白的科室顺序。
  departments: [department_schema]

route_schema = new Schema route_schema, {versionKey: false, id: false}

route_schema.statics.cache = (cb) ->
  redis_client.on "message", (channel, message) =>
    @set_route_hash_cache() if channel is 'touch_route'
  @set_route_hash_cache(cb)

route_schema.statics.set_route_hash_cache = (cb) ->
  @find()
  .exec (error, routes) =>
    return cb error if error
    @routes = routes
    cb?()

route_schema.statics.random = (profile) ->
  routes = @routes.filter((route) -> route.match profile)
  n = _.random(routes.length-1)
  routes[n]

route_schema.methods.match = ({sex,age}) ->
  sex is @sex and (not age or @age_lt <= age <= @age_ut)

module.exports = route_schema
