mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
event    = require "../../Shared/event.coffee"


doctor_check_time_schema =
  _id: ObjectId
  department_id: String
  start: event
  finished: event

doctor_check_time_schema = new Schema(doctor_check_time_schema, {versionKey: off, id: off})

module.exports = doctor_check_time_schema
