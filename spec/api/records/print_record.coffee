should  = require "should"
request = require "superagent"

describe "api:打印报告", ->
  before (done) ->
    body =
      _id: 'test'
      pwd: 'hswk123'
    request
    .post('http://test.healskare.com:5124/authentication')
    .query('app=运营')
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

  describe "标记打印", ->
    it '档案状态为已打印，打印成功', (done) ->
      request
      .post('http://test.healskare.com:5124/records/10000742/report_printed')
      .send({})
      .set('X-API-Key', 'foobar')
      .set('Accept', 'application/json')
      .end (res) ->
        return done(res.text) unless res.ok
        res.status.should.eql 200
        done()

  describe "标记打印", ->
    it '档案状态为检查中，拒绝打印', (done) ->
      request
      .post('http://test.healskare.com:5124/records/10023617/report_printed')
      .send({})
      .set('X-API-Key', 'foobar')
      .set('Accept', 'application/json')
      .end (res) ->
        res.status.should.eql 403
        done()

