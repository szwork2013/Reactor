should       = require 'should'
models       = require "../../../models"
record = null

describe "验证年龄", ->
  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record =
        profile:
          name: '年龄'
          sex: '女'
          age: 25
          id:  null
          check_date: '2013-07-04'
          check_time: 'A'
      record = new Record record
      done()

  describe "年龄是0至120之间的整数", ->
    it '年龄不为数字', (done) ->
      record.profile.age = 'asdf'
      record.save (err, record) ->
        error = err?['name'] or ''
        error.should.eql 'CastError'
        done()

    it '年龄不为整数', (done) ->
      record.profile.age = '50.12'
      record.save (err, record) ->
        error = err?['errors']?['profile.age']?['type'] or ''
        error.should.eql '无效的0至120之间的整数年龄'
        done()

    it '年龄小于0', (done) ->
      record.profile.age = -10
      record.save (err, record) ->
        error = err?['errors']?['profile.age']?['name'] or ''
        error.should.eql 'ValidatorError'
        done()

    it '年龄大于120', (done) ->
      record.profile.age = 121
      record.save (err, record) ->
        error = err?['errors']?['profile.age']?['name'] or ''
        error.should.eql 'ValidatorError'
        done()

    it '年龄等于0', (done) ->
      record.profile.age = 0
      record.save (err, record) ->
        return done err if err
        record.profile.age.should.eql 0
        done()

    it '年龄等于120', (done) ->
      record.profile.age = 120
      record.save (err, record) ->
        return done err if err
        record.profile.age.should.eql 120
        done()

    it '年龄在0到120之间', (done) ->
      record.profile.age = 112
      record.save (err, record) ->
        return done err if err
        record.profile.age.should.eql 112
        done()

    it '年龄为null', (done) ->
      record.profile.age = null
      record.save (err, record) ->
        return done err if err
        done() if record.profile.age == null
