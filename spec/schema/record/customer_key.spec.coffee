should = require 'should'
models = require "../../../models"
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
record = null

describe "验证身份标识", ->

  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record =
        _id: new ObjectId
        profile:
          name: '王玲'
          sex: '女'
          age: 100
          id: '421023198806030445'
          tel: null
          check_date: '2013-07-04'
          check_time: 'A'
      record = new Record record
      done()

  describe "身份标识应当与出生日期、性别、姓名同步", ->
    it '新增档案', (done) ->
      record.save (err, record) ->
        return done err if err
        record.customer_key.should.eql '1988-06-03|女|王玲'
        done()

    it '修改档案', (done) ->
      record.profile.name = '王琴'
      record.profile.id = '500222198105267734'
      record.save (err, record) ->
        return done err if err
        record.customer_key.should.eql '1981-05-26|女|王琴'
        done()

    it '当无身份证号时，客户身份标识为个检、性别、姓名', (done) ->
      record.profile.name = '王琴'
      record.profile.id = null
      record.save (err, record) ->
        return done err if err
        record.customer_key.should.eql '个检|女|王琴'
        done()
    
    it '当无身份证号时，客户身份标识为公司名称、性别、姓名', (done) ->
      record.profile.name = '王琴'
      record.profile.id = null
      record.profile.batch = '51b18dd9f1ae2f135c000004'
      record.save (err, record) ->
        return done err if err
        record.customer_key.should.eql '福临德|女|王琴'
        done()

