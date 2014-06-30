should = require 'should'
models = require "../../../models"
record = null

describe "验证身份证号或出生日期", ->

  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record =
        profile:
          name: '张三'
          sex: '女'
          age: 100
          id: '421023'
          check_date: '2013-07-04'
          check_time: 'A'
      record = new Record record
      done()

  describe "id 可能是身份证号、出生日期、null", ->
    it '无效身份证号', (done) ->
      record.save (err, record) ->
        error = err?['errors']?['profile.id']?['type'] or ''
        error.should.eql '无效的二代身份证编号或者无效的出生日期'
        done()

    it '有效身份证号，变更年龄，身份证决定年龄', (done) ->
      record.profile.age = 100
      record.profile.id = '421023198806030445'
      record.save (err, record) ->
        return done err if err
        record.profile.age.should.eql 25
        done()
   
    it '有效出生日期，变更年龄，生日决定年龄', (done) ->
      record.profile.age = 100
      record.profile.id = '1988-06-03'
      record.save (err, record) ->
        return done err if err
        record.profile.age.should.eql 25
        done()

    it '无效出生日期', (done) ->
      record.profile.id = '2013-02-83'
      record.save (err, record) ->
        error = err?['errors']?['profile.id']?['type'] or ''
        error.should.eql '无效的二代身份证编号或者无效的出生日期'
        done()

    it 'null，年龄不变', (done) ->
      record.profile.age = 100
      record.profile.id  = null
      record.save (err, record) ->
        return done err if err
        record.profile.age.should.eql 100
        done()

