should  = require "should"
request = require "superagent"
_       = require "underscore"

describe "api:查看电话号码是否存在", ->

  describe "电话号码", ->
    it '电话号码存在', (done) ->
      request
      .get('http://test.healskare.com:5124/tel/13523652145')
      .end (res) ->
        return done(res.text) unless res.ok
        res.text.should.eql 'true'
        done()

    it '电话号码不存在', (done) ->
      request
      .get('http://test.healskare.com:5124/tel/13811237854')
      .end (res) ->
        return done(res.text) unless res.ok
        res.text.should.eql 'false'
        done()

