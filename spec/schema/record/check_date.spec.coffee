should = require 'should'
models = require "../../../models"
record = null

describe "验证健检日期", ->
  before (done) ->
    models 'test.healskare.com', (error, {Record}) ->
      return done error if error
      record =
        profile:
          name: '张三'
          sex: '男'
          age: 30
          id: null
          check_date: '2013-06-23'
          check_time: 'A'
        appeared: []
      record = new Record record
      done()
  
  describe "未到场客人的健检日期是预约日期，到场客人的健检日期是客人到场第一日", ->
    
    it '未到场时，健检日期是预约日期', (done) ->
      record.save (err, record) ->
        return done err if err
        record.profile.check_date.should.eql '2013-06-23'
        done()

    it '第一次到场时，健检日期是客人到场第一日', (done) ->
      record.orders.addToSet
        _id: '51b28ecca9551a5e79000006'
        name: '易康网（入职）'
        price: 0
        paid: 2
        category: 'package'

      record.samplings.addToSet
        "biochemistry" : true
        "_id" : "1000075701"
        "name" : "黄色采血管（1）"
        "color" : "#FFA54F"
        "tag" : "生化"
        "departments" : ["生化检验"]
        "status" : "已采样",
        "sample" :
          "date_number" : 1376527837477
          "date_string" : "2013-08-15"
      record.appeared.push '2013-06-20'
      record.save (err, record) ->
        return done err if err
        record.profile.check_date.should.eql '2013-06-20'
        done()
    
    it '第二次到场时，健检日期是客人到场第一日', (done) ->
      record.appeared.push '2013-06-21'
      record.save (err, record) ->
        return done err if err
        record.profile.check_date.should.eql '2013-06-20'
        done()
