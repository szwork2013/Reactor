should  = require "should"
request = require "superagent"

describe "api:新增档案", ->
  before (done) ->
    body =
      _id: 'test'
      pwd: 'hswk123'
    request
    .post('http://test.healskare.com:5124/authentication')
    .query('app=检查')
    .set('Content-Type', 'application/json')
    .send(body)
    .end (res) ->
      return done(res.text) unless res.ok
      res.body.credential.should.exists
      res.body._id.should.exists
      res.body.name.should.eql 'test'
      res.body.roles.should.exists
      res.body.trust.should.exists
      done()

  describe "新增档案", ->
    it '新增个人档案', (done) ->
      body =
        profile:
          name: '张三'
          sex: '女'
          age: 100
          id: '421023198806030445'
          check_date: '2013-07-04'
          check_time: 'A'
      request
      .post('http://test.healskare.com:5124/records')
      .send(body)
      .set('X-API-Key', 'foobar')
      .set('Accept', 'application/json')
      .end (res) ->
        return done(res.text) unless res.ok
        res.body.barcode.should.exists
        done()

    it '新增团体档案', (done) ->
      body =
        profile:
          name: '王琴'
          sex: '女'
          age: 24
          id: null
          check_date: '2013-07-04'
          check_time: 'A'
          batch: '51b18dd9f1ae2f135c000004'
          division: '部门1'
      request
      .post('http://test.healskare.com:5124/records')
      .send(body)
      .set('X-API-Key', 'foobar')
      .set('Accept', 'application/json')
      .end (res) ->
        return done(res.text) unless res.ok
        res.body.barcode.should.exists
        done()
