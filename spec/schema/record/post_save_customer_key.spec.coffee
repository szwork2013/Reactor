should   = require 'should'
models   = require "../../../models"
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
record   = null
record_model = null

describe "自动为之前客人更正出生日期与身份标识", ->

  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record_model = Record
      record =
        profile:
          name: '测试身份标识'
          sex: '女'
          age: 25
          id: null
          tel: null
          check_date: '2013-07-04'
          check_time: 'A'
      record = new Record record
      done()

  describe "同步客人之前的身份标识中的出生日期", ->
    it '同一人，无身份证，有source', (done) ->
      record.save (err, record) ->
        return done err if err
        record.customer_key.should.eql '个检|女|测试身份标识'
        delete record._id
        done()

    it '同一个，有身份证', (done) ->
      record = record.toObject()
      record._id = new ObjectId
      record.barcode = undefined
      record.profile.id = '421023198806030445'
      record = new record_model record
      record.save (err, record) ->
        return done err if err
        record.customer_key.should.eql '1988-06-03|女|测试身份标识'
        done()
