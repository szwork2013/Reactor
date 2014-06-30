# 保存科室检查结果
#
# ## 保存科室检查结果
#   + **资源地址**
#   + `/records/:barcode/departments/:department_id`
#   + **例**
#     * 【医生工作站】
#     * `req.body`内容分别如下：
#      {
#        _id: "280000000000000000000000",
#        name: "科室1"
#        timestamp: '1375438756883'
#        category: "clinic"
#        normal: "正常"
#        items:[
#          {
#            _id: "280000000000000000000001"
#            name: "项目1"
#            abbr: "简写"
#            conditions: []
#          }
#        ]
#      }
# ## 数据服务（应用于个人注册）
#   + 新增客人档案
#   + 新增成功返回{}，失败发送错误信息。
moment   = require "moment"
_        = require 'underscore'
mongoose = require "mongoose"

app.put '/records/:barcode/departments/:department_id/items', authorize('mo', 'admin'), (req, res) ->
  {barcode, department_id} = req.params
  {Record} = req.models
  do save_department = ->
    Record.barcode barcode, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 404 unless record
      department = record.departments.id department_id
      return res.send 404 unless department

      # 科室保存时，除非保存前该科室`已完成`，除：
      #
      # 1. 下列非现场诊断，但仍使用本接口的科室：
      #
      #   + 宫颈超薄细胞学检测（/宫颈/）；
      #   + 放射科（/放射/）；
      #
      # 2. 下列录入科室（排除后影响事实吻合度）：
      #
      #   + 血压（/血压/）
      #   + 身高体重（/身高体重/）
      #
      # 推入一站检查信息：
      # 
      #   + 行为文字为科室名称。
      #   + 如会话中没有起始时间，以当前时间代替，同时更新会话。
      unless department.status in ['已完成']
        unless /宫颈|放射|血压|身高体重/.test(department.name)
          now = Date.now()
          record.add_stop
            user_id   : req.user?._id
            user_name : req.user?.name
            start     : req.session.stops[barcode] ?= now
            action    : department.name
            end       : now
            date      : moment(now).format('YYYY-MM-DD')

      items = department.items
      # TODO: 未付费考虑持久化。
      for item in req.body
        index = items.indexOf items.id item._id
        continue if index is -1
        # 放弃或延期需要客户端传递，其余情况允许不交换status，仍可以将放弃设置成未完成。
        item.status or = undefined
        item.note or = undefined
        item.value or = undefined
        item.normal or = undefined
        item.description or = undefined
        _.extend items[index], item
        if department.name is '放射科'
          items[index].checking =
            finished: req.event
        console.log 'x', items[index].normal if item.name is '心律'
        # items.set index, item
      department.appeared = moment().format('YYYY-MM-DD') unless department.appeared?
      department.checking =
        finished: req.event
      today = moment().format('YYYY-MM-DD')
      record.doctor_check_time.push department_id: department._id, finished: req.event
      record.appeared.addToSet today unless today in record.appeared and department.name isnt '放射科'
  
        
      record.save (error) ->
        return save_department() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        res.send {}
