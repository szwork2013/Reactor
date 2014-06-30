mongoose   = require 'mongoose'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

schema =
  # 编号
  _id: ObjectId

  # 名称（reservation_time_ranges预约时间段|special_rooms特殊科室）
  name: String

  # 预约时段对应内容
  content: Object

configuration_schema = new Schema schema, {versionKey: off}

configuration_schema.statics.cache = (cb) ->
  @find()
  .exec (error, configurations) =>
    return cb error if error
    for configuration in configurations
      @[configuration.name] = configuration.content
      # TODO: 如果需要针对性地对某个配置进行深度处理，指明这是哪个配置。
      # 这样处理行吗？
      if configuration.name is 'special_rooms'
        for item in configuration.content
          @[item.name] = item if item.name
    cb()

module.exports = configuration_schema
