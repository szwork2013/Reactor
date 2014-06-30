mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
event = require './event.coffee'

module.exports =
    disk_and_position: String
    analyze_start: event
    audit: event
