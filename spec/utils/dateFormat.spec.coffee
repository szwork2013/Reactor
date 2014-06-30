should = require 'should'
{dateFormat} = require "../../utils/dateformat.coffee"
moment = require 'moment'

describe "格式化日期", ->
  
  describe "日期格式转化", ->
    
    it '2012-12-25  -> 2012年12月25日 周二', (done) ->
      dateFormat('2012-12-25').should.eql '2012年12月25日 周二'
      done()

    year = moment().year() - 1
    it "#{year}-12-25  -> 去年12月25日 周三", (done) ->
      dateFormat("#{year}-12-25").should.eql '去年12月25日 周三'
      done()
   
    it "#{moment().year()}-01-01  -> 1月1日 周三", (done) ->
      dateFormat("#{moment().year()}-01-01").should.eql '1月1日 周三'
      done()

    date_4 = "#{moment().year()}-#{moment().format('MM')}-#{}"
    it "#{date_4}  -> 上周五 ", (done) ->
      dateFormat(date_4).should.eql '上周五'
      done()
    
    it '2014-03-10  -> 昨天 周一', (done) ->
      dateFormat('2014-03-10').should.eql '昨天 周一'
      done()

    it '2014-03-09  -> 前天 周日', (done) ->
      dateFormat('2014-03-09').should.eql '前天 周日'
      done()
    
    it '2014-03-11  -> 今天', (done) ->
      dateFormat('2014-03-11').should.eql '今天'
      done()

    it '2014-03-12  -> 明天 周三', (done) ->
      dateFormat('2014-03-12').should.eql '明天 周三'
      done()
    
    it '2014-03-13  -> 后天 周四', (done) ->
      dateFormat('2014-03-13').should.eql '后天 周四'
      done()

    it '2014-03-14  -> 本周五', (done) ->
      dateFormat('2014-03-14').should.eql '本周五'
      done()
    
    it '2014-03-17  -> 下周一', (done) ->
      dateFormat('2014-03-17').should.eql '下周一'
      done()

    it '2014-03-29  -> 3月29日 周六', (done) ->
      dateFormat('2014-03-29').should.eql '3月29日 周六'
      done()
    
    it '2015-01-01  -> 明年1月1日 周四', (done) ->
      dateFormat('2015-01-01').should.eql '明年1月1日 周四'
      done()

    it '2016-02-01  -> 2016年2月1日 周一', (done) ->
      dateFormat('2016-02-01').should.eql '2016年2月1日 周一'
      done()
