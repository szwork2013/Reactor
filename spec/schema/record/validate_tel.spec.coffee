should = require 'should'
models = require "../../../models"
record = null

describe "验证电话号码", ->

  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record =
        profile:
          name: '王玲'
          sex: '女'
          age: 100
          id: '421023198806030445'
          tel: '13811237854'
          check_date: '2013-07-04'
          check_time: 'A'
      record = new Record record
      done()

  describe "移动电话或固话（7或8位可配置）（可能含区号或分机号）", ->
    it '移动电话', (done) ->
      record.save (err, record) ->
        return done err if err
        done()

    it '固话3位区号，8位号码', (done) ->
      record.profile.tel = '010-10000888'
      record.save (err, record) ->
        return done err if err
        done()

    it '固话8位号码', (done) ->
      record.profile.tel = '10000888'
      record.save (err, record) ->
        return done err if err
        done()

    it '固话7位号码', (done) ->
      record.profile.tel = '1000088'
      record.save (err, record) ->
        return done err if err
        done()

    it '固话3位区号，8位号码，6位区号', (done) ->
      record.profile.tel = '010-10000888-123456'
      record.save (err, record) ->
        return done err if err
        done()

    it '错误的手机号码', (done) ->
      record.profile.tel = '12310000888-1234'
      record.save (err, record) ->
        error = err?['errors']?['profile.tel']?['type'] or ''
        error.should.eql '无效的移动电话或固话'
        done()
