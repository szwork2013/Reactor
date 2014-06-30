should = require 'should'
jsdom = require "jsdom"

describe "导检卡API测试", ->
  
  describe "导检卡", ->

    it "打印导检卡", (done) ->

      start = (new Date).valueOf()
      # jsdom 使用报错，未解决
      # Exception: TypeError: Cannot read property 'implementation' of undefined
      jsdom.env
        html: "http://test.healskare.com:5124/records/10023177/guidance_card"
        done: (errors, window) ->
          doc = window.document
          doc.querySelector("#name").innerHTML.should.eql '傅瑶'
          doc.querySelector("#sex").innerHTML.should.eql '女'
          doc.querySelector("#age").innerHTML.should.eql '47'
          doc.querySelector("#month").innerHTML.should.eql '11-07'
          doc.querySelector("#week").innerHTML.should.eql '星期四'
          doc.querySelector("#time").innerHTML.should.eql '7:30-8:30'
          doc.querySelector("#company").innerHTML.should.eql '罗曼赛亚'
          doc.querySelector("#division").innerHTML.should.eql '罗曼赛亚'
          doc.querySelector("#note").innerHTML.should.eql ''
          doc.querySelectorAll("text")[0].innerHTML.should.eql '10023177'
          doc.querySelector('#rooms > div:nth-child(1)').getAttribute('status').should.eql 'complete'
          doc.querySelector('#rooms > div:nth-child(1) > span:nth-child(1)').innerHTML.should.eql '采血室'
          doc.querySelector('#rooms > div:nth-child(1) > span:nth-child(2)').innerHTML.should.eql '102'

          doc.querySelector('#rooms > div:nth-child(2)').getAttribute('status').should.eql 'complete'
          doc.querySelector('#rooms > div:nth-child(2) > span:nth-child(1)').innerHTML.should.eql '口腔科'
          doc.querySelector('#rooms > div:nth-child(2) > span:nth-child(2)').innerHTML.should.eql '115'

          doc.querySelector('#rooms > div:nth-child(6)').getAttribute('status').should.eql 'complete'
          doc.querySelector('#rooms > div:nth-child(6) > span:nth-child(1)').innerHTML.should.eql '妇科'
          doc.querySelector('#rooms > div:nth-child(6) > span:nth-child(2)').innerHTML.should.eql '212'

          doc.querySelector('#rooms > div:nth-child(7)').getAttribute('status').should.eql 'complete'
          doc.querySelector('#rooms > div:nth-child(7) > span:nth-child(1)').innerHTML.should.eql '外科'
          doc.querySelector('#rooms > div:nth-child(7) > span:nth-child(2)').innerHTML.should.eql '213'

          doc.querySelector('#rooms > div:nth-child(8)').getAttribute('status').should.eql 'complete'
          doc.querySelector('#rooms > div:nth-child(8) > span:nth-child(1)').innerHTML.should.eql '内科'
          doc.querySelector('#rooms > div:nth-child(8) > span:nth-child(2)').innerHTML.should.eql '107'

          done()
