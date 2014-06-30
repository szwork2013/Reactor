# 新增批次信息
#
# ## 创建批次
#   + **资源地址**
#   + `/batches/:id`
#   + **例**
#     * `req.body` 内容分别如下：
#      [
#        {
#         "profile": {
#            basic: {
#              name:'王玲',
#              sex:'female',
#              age:25
#             }
#            batch: '4e5bb37258200ed9aabc5d11'           (团体补录时有此键)
#            division:'研发部'
#            .......
#          }
#         "orders": [...]
#        }
#      ]
#
# ## 数据服务（应用于团检注册）
#   + 创建批次和套餐
#   + 新增成功返回{}，失败发送错误信息。
mongoose = require "mongoose"
ObjectId = mongoose.Types.ObjectId
_        = require "underscore"
async    = require "async"

app.post '/batches/:batch_id/records', authorize('mo', 'admin'), (req, res) ->
  {batch_id} = req.params
  {Batch, Record, Seq, Route} = req.models
  records = req.body
  return res.send {} unless records.length
  begin = (new Date).valueOf()
  {_id, name, date_number, date_string} = req.event
  data =
    user_id: _id
    name: name
    date_number: date_number
    date_string: date_string
  Batch.getProductbyBatch batch_id, (error, product) ->
    return res.send 500, error.stack if error
    return res.send 404 unless product?.batch?.company
    package_ids = product.configurations?.map (c) -> String(c._id)
    orders = _.flatten(_.pluck(records, 'orders'))?.filter (order) -> order?.category is 'package'
    records_package_ids = _.uniq(orders.map((order) -> order._id))
    return res.send 403 if records_package_ids.filter((id) -> id not in package_ids).length
    Route.find()
    .select('_id age_ut age_lt sex')
    .exec (error, routes) ->
      return res.send 500, error.stack if error
      wait_add_records = records.filter (record) -> not record._id
      Seq.retrieveSeq 'records', wait_add_records.length, (error, seq) ->
        return res.send 500, error.stack if error
        start_seq = seq - wait_add_records.length
        regist_record = (record, callback) ->
          record.profile.batch  = batch_id
          record.profile.category = 'group'
          record.profile.source = product.batch.company
          console.log 'a'
          if record._id
            console.log 'b'
            updator =
              'profile.name': record.profile.name
              'profile.age': record.profile.age
              'profile.sex': record.profile.sex
              'profile.source': record.profile.source
              'profile.check_date': record.profile.check_date
              'profile.check_time': record.profile.check_time
              'profile.batch': record.profile.batch
              'profile.division': record.profile.division ? ''
              'profile.notes': record.profile.notes or []
            if record.profile.id
              console.log 'c'
              updator['profile.id'] = record.profile.id
              updator['profile.birthday'] = Record.setBirthday(record.profile.id)
              updator['profile.age'] = Record.setAge(updator['profile.birthday'])
            Record.findOne({_id: record._id})
            .select('orders')
            .exec (error, db_record) ->
              console.log 'd'
              console.log error.stack, error.errors if error
              orders = db_record.orders
              orders_ = orders?.filter((order) -> order.paid in [0, 2, 3]) or []
              for order in orders_ when not record.orders.some((order_) -> order_._id is order._id.toString())
                history = _.clone data
                history.paid = order.paid = -1
                history.price = if order.actual_price? then order.actual_price else order.price
                order.histories.push history
              console.log 'e'
              for order in record.orders
                order.histories or = []
                history = _.clone data
                history.paid  = order.paid
                history.price = if order.actual_price? then order.actual_price else order.price
                db_order = orders?.id order._id
                if db_order
                  if order.paid isnt db_order.paid or order.actual_price isnt db_order.actual_price \
                  or order.price isnt db_order.price
                    db_order.histories.push history
                else
                  order.histories.push history
                  orders.push order
              console.log 'f'
              updator['orders'] = orders
              Record.update {_id: record._id}, { '$set': updator }, { safe: true }
              , (error, numberAffected) ->
                console.log 'g'
                console.log error.stack, error.errors if error
                callback()
          else
            record.registration = req.event
            record = new Record record
            {age, sex} = record.profile
            profile =
              age: age
              sex: sex
            record.profile.source_safe  = on
            record.profile.package_safe = on
            start_seq += 1
            record.barcode = Seq.identity_to_barcode start_seq
            record.route   = Record.getRoute profile, routes
            orders         = Record.addOrder profile, product, record.orders
            console.log 'ORDERS', profile, product, record.orders
            if orders
              for order in orders
                history = _.clone data
                history.paid = order.paid
                history.price = if order.actual_price? then order.actual_price else order.price
                order.histories.push history
              record.orders = orders
              # console.log 'PRE', JSON.stringify record
              record.save (error, record) ->
                console.log error if error
                return callback error.stack if error
                record.update_guidance_card_hash (error) ->
                  console.log error if error
                  return callback error.stack if error
                  record.save (error, record) ->
                    return callback error.stack if error
                    callback()
            else
              callback()
        # console.log 'TOTAL', JSON.stringify records
        records = records.map (x) -> (callback) -> regist_record x, callback
        async.parallel records, (err, result) ->
          console.log err if err
          end = (new Date).valueOf()
          console.log (end - begin)
          res.send {}
