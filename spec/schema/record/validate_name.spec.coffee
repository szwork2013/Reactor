should       = require 'should'
models       = require "../../../models"   
record = null

describe "验证姓名", ->
  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record = new Record
      done()

  describe "汉字姓名中不得包含全、半角空格", ->
    it '中文姓名', (done) ->
      record.profile.name = " 张 三 "
      expected = "张三"
      record.profile.name.should.eql expected
      done()

    it '英文姓名', (done) ->
      record.profile.name = " Day lily "
      expected = "Day lily"
      record.profile.name.should.eql expected
      done()
