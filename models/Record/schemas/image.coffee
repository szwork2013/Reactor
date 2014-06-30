mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId

image_schema =
  _id:  ObjectId
  tag:  String
  date: String
  conclusion: String
  detail: String

image_schema = new Schema(image_schema, {versionKey: off, id: off})

module.exports = image_schema
