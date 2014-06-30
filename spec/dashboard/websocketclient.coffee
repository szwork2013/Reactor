should = require 'should'
models = require "../../models"
moment = require "moment"
_      = require 'underscore'
connect_str = "ws://test.healskare.com:8080"
WebSocketClient = require('websocket').client

connection1 = null
connection2 = null
Record2 = null
record  = null
    
describe "验证仪表盘", =>
  before (done) =>
    models 'test.healskare.com', (error, {Record}) =>
      return done error if error
      client1 = new WebSocketClient()
      client2 = new WebSocketClient()
      client1.connect connect_str
      client2.connect connect_str
      client1.on 'connectFailed', (error) ->
        console.log 'Connect Error: ' + error.toString()
      client2.on 'connectFailed', (error) ->
        console.log 'Connect Error: ' + error.toString()
      client1.on 'connect', (conn1) =>
        conn1.on 'error', (error) ->
          console.log "Connection Error: " + error.toString()
        conn1.on 'close', () ->
          console.log 'echo-protocol Connection Closed'
        connection1 = conn1
        client2.on 'connect', (conn2) =>
          conn2.on 'error', (error) ->
            console.log "Connection Error: " + error.toString()
          conn2.on 'close', () ->
            console.log 'echo-protocol Connection Closed'
          connection2 = conn2
          date = moment().format('YYYY-MM-DD')
          record =
            profile:
              source : "个检"
              name: '王琴'
              sex: '女'
              age: 24
              id: null
              check_date: date
            appeared: [date]
            departments:[
              _id: '010000000000000000000000'
              name: '口腔科'
              category: 'clinic'
              status: '未完成'
              checking:
                finished:
                  date_number: 1376888599431
                  date_string: '2013-08-19'
                  _id: '040000000000000000000005'
                  name: '张三'
              items: [
                _id: '010000000000000000000001'
                name: '颌面部'
                status: '未完成'
                conditions: []
               ,
                _id: '010000000000000000000004'
                name: '牙齿'
                status: '已完成'
                conditions: [
                  name: '牙齿劈裂'
                 ,
                  name: '牙齿缺失'
                  detail: '左上1牙齿缺失'
                ]
              ]
             ,
              _id: '900000000000000000000000'
              name: "颈部彩超"
              category: "clinic"
              status: "未完成"
              checking:
                finished:
                  date_number: 1376888599433
                  date_string: "2013-08-19"
                  _id: '040000000000000000000006'
                  name: "刘津京"
              items: [
                _id: "900000000000000000000001"
                name: "甲状腺"
                status: "已完成"
                conditions: [
                  name: '甲状腺单发结节'
                  detail: '甲状腺左叶单发结节0.6cm×0.4cm'
                ]
               ,
                _id: "900000000000000000000002"
                name: "颈动脉"
                status: "未完成"
                conditions: []
              ]
            ]
            orders: [
              _id: '201301040100000000000002'
              category: 'combo'
              name: '甲状腺超声'
              actual_price: 120
              price: 120
              paid: 1
             ,
              _id: '201301040200000000000002'
              category: 'combo'
              name: '颈动脉超声'
              actual_price: 120
              price: 120
              paid: 1
             ,
              _id: '201301041100000000000001'
              category: 'combo'
              name: '口腔科'
              actual_price: 25
              price: 25
              paid: 1
            ]
            status: '检查中'
          record = new Record record
          record.save (error, record) =>
            return done error if error
            done()

  describe "仪表盘", =>
    it '初始化科室情况:颈部彩超', (done) ->
      connection1.sendUTF "SUBSCRIBE:CHECK_SITUATIONS_INIT:颈部彩超"
      connection1.on 'message', (message) =>
        messages =  message.utf8Data
        messages = JSON.parse messages
        found_record = _.find messages, (message) -> message.name is '王琴'
        found_record.finished.should.include '颈部彩超'
        found_record.unfinished.should.include '颈部彩超'
        found_record.substandard.items.should.include '甲状腺'
        found_record.wait_inspect.should.eql off
        done()

    it '初始化体检中心情况', (done) ->
      connection2.sendUTF "SUBSCRIBE:CHECK_SITUATIONS_INIT:体检中心"
      connection2.on 'message', (message) =>
        messages =  message.utf8Data
        messages = JSON.parse messages
        found_record = _.find messages, (message) -> message.name is '王琴'
        found_record.finished.should.include '颈部彩超'
        found_record.unfinished.should.include '颈部彩超'
        done()
