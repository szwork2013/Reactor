should  = require "should"
request = require "superagent"
_       = require "underscore"

describe "api:查询档案", ->

  describe "查询档案", ->
    it '查询档案时，*代表匹配0个或多个字符', (done) ->
      request
      .get('http://test.healskare.com:5124/records')
      .query('keywords=*csfsk*')
      .end (res) ->
        return done(res.text) unless res.ok
        names = res.body.map (record) -> record.profile.name
        names.should.include '测试放射科2'
        done()

    it '查询档案时，?代表匹配1个字符', (done) ->
      request
      .get('http://test.healskare.com:5124/records')
      .query('keywords=谢??')
      .end (res) ->
        return done(res.text) unless res.ok
        names = res.body.map (record) -> record.profile.name
        names.should.include '谢玉兰'
        done()
