# 保存图片到磁盘上
#
# ## 保存图片到磁盘上
#   + **资源地址**
#   + `/records/:barcode/images`
# ## 数据服务
#   + 新增图片
#   + 新增成功返回{}，失败发送错误信息。

mongoose = require "mongoose"
async    = require "async"
ObjectId = mongoose.Types.ObjectId
{exec}   = require 'child_process'
fs       = require 'fs'
moment   = require 'moment'

app.post '/records/:barcode/images', authorize('mo', 'admin'), (req, res) ->
  {Record} = req.models
  images = []
  console.log req.files, 'files'
  barcode = req.params.barcode
  for key, image of req.files
    images.push order: key, _id: new ObjectId, tag: image.name, date: moment().format('YYYY-MM-DD'), path: image.path
  images = images.sort((a, b) -> if a.order > b.order then 1 else -1)
  tasks = images.map (image) ->
    (callback) ->
      fs.rename image.path, "./public/images/#{image._id}.jpeg", (error) ->
        return callback error if error
        callback()

  async.parallel tasks, (error) ->
    counter = 0
    do add_image = ->
      Record.barcode req.params.barcode, (error, record) ->
        return res.send 500, error.stack if error
        return res.send 403 unless record
        {_id, tag} = images[0]
        record.profile.live_portrait = _id if tag is '头像'
        if tag in ['头像', '宫颈超薄细胞学检测', '心电图']
          record.images = record.images.filter((image) -> image.tag isnt tag)
        for image in images
          record.images.addToSet image
        if tag isnt '头像' and not record.appeared.length
          record.appeared.addToSet moment().format('YYYY-MM-DD')


        # 如影像为放射科影像（/放射/），
        # 推入一站检查信息，行为文字为：放射科:胸部。
        if /放射/.test(tag)
          now = Date.now()
          record.add_stop
            user_id   : req.user?._id
            user_name : req.user?.name
            start     : req.session.stops[barcode] ?= now
            action    : tag
            end       : now
            date      : moment(now).format('YYYY-MM-DD')

        record.save (error) ->
          return add_image() if error instanceof mongoose.Error.VersionError
          return res.send 500, error.stack if error
          res.set '_id', _id
          res.send _id: _id if tag isnt '宫颈超薄细胞学检测'
          if tag is '宫颈超薄细胞学检测'
            exec "convert ./public/images/#{_id}.jpeg -crop 488x301+268+231 ./public/images/#{_id}.jpeg", (error) ->
              return res.send error if error
              res.send _id: _id
