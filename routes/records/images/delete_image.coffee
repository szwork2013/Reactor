# 把图片从磁盘上删除
#
# ## 把图片从磁盘上删除
#   + **资源地址**
#   + `/records/:barcode/images/:id`
# ## 数据服务
#   + 删除图片
#   + 删除成功返回{}，失败发送错误信息。

fs       = require "fs"
mongoose = require "mongoose"
_        = require "underscore"

app.delete /^\/records\/(\w+)\/images\/(\w+)(?:\.([jpeg]+))?$/, authorize('mo', 'admin'), (req, res) ->
  {Record} = req.models
  barcode  = req.params[0]
  _id      = req.params[1]
  console.log barcode, _id
  do delete_image = ->
    Record.barcode barcode, {paid_all: on}, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 400 unless record
      live_portrait = record.profile.live_portrait?.toString()
      image         = record.images.id _id
      image         = _.find(record.images, (image) -> image.tag is _id) unless image
      return res.send 404 if live_portrait isnt _id and not image
      if live_portrait is _id
        record.profile.live_portrait = undefined
      record.images.remove image
      record.save (error) ->
        return delete_image() if error instanceof mongoose.Error.VersionError
        return res.send 500, error.stack if error
        fs.unlink "./public/images/#{image._id}.jpeg", (error) ->
          return res.send 500, error if error
          res.send _id: image._id
