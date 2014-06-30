mongoose   = require 'mongoose'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

# TODO: 本阶段暂不考虑。
# TODO: 以`Cards`概念建模。
schema =
  # 
  _id: ObjectId

depositCardSchema = new Schema(schema, { versionKey: false, id: false })

module.exports = depositCardSchema
