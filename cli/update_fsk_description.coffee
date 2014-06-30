models   = require '../models'
_        = require 'underscore'
fs       = require 'fs'
#barcodes = _.uniq fs.readFileSync("./barcodes.txt").toString().split('\r\n').filter((barcode) -> barcode)
async    = require 'async'

models 'hswk.healskare.com', (error, models, settings) ->
  Record = models.Record
  console.log "A"
  #console.log barcodes.length
  #Record.find({appeared: {'$lte': '2013-11-27'}, 'mark_update2': {'$exists': false}})
  #Record.find({barcode: {'$in': barcodes}})
  #Record.find({appeared: {'$gte':'2013-12-03'}})
  barcodes = [
    '10016055'
  ]
  Record.find({barcode: {'$in': barcodes}})
  .select('barcode')
  .exec (error, records) ->
    console.log records.length, 'length'
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length, 'count'
    #barcodes = ['10021474']
    #barcodes = ['10010403', '10010402', '10010399', '10010401', '10010400']
    tasks = barcodes.map (barcode) ->
      console.log barcode
      (callback) ->
        Record.barcode barcode, {paid_all:on}, (error, record) ->
          callback() unless record
          fsk_department = _.find record.departments, (d) -> d.name is '放射科'
          if fsk_department
            jz_items = fsk_department.items.filter (item) -> item.name.match /颈椎/
            jz_item  = _.find jz_items, (item) -> item.status in ['未完成', '待检验']
            jz_item?.name = '颈椎'
            jz_item2 = _.find jz_items, (item) -> item.status is '已完成'
            if jz_item and jz_items.length > 1
              console.log jz_item, 'jz_item'
              fsk_department.items = fsk_department.items.remove jz_item
            if jz_item2
              jz_item2._id = '300000000000000000000001'
              jz_item2.name = '颈椎'
              images = record.images.filter (image) -> image.tag.match /颈椎/
              for image in images
                image.tag = '放射科:颈椎'
              jz_item2.description = images?[0]?.detail
            yz_items = fsk_department.items.filter (item) -> item.name.match /腰椎/
            yz_item  = _.find yz_items, (item) -> item.status in ['未完成', '待检验']
            yz_item?.name = '腰椎'
            yz_item2 = _.find yz_items, (item) -> item.status is '已完成'
            if yz_item and yz_items.length > 1
              console.log yz_item, 'yz_item'
              fsk_department.items = fsk_department.items.remove yz_item
            if yz_item2
              yz_item2._id = '300000000000000000000007'
              yz_item2.name = '腰椎'
              images = record.images.filter (image) -> image.tag.match /腰椎/
              for image in images
                image.tag = '放射科:腰椎'
              yz_item2.description = images?[0]?.detail
              #xb_items = fsk_department.items.filter (item) -> item.name.match /胸部/
              #xb_item  = _.find xb_items, (item) -> item.status in ['待检验', '未完成']
              #xb_item?.name = '胸部'
              #xb_item?.status = '已完成'
              #xb_item?.normal = '胸部正位像心肺未见异常。'
              #xb_item?.description = '两侧胸廓对称，骨质未见异常。两侧肺野清晰，未见实质病变；两肺门及纵隔影无增大；双膈面\n光整， 双侧肋膈角清晰锐利；心影大小在正常范围。'
              #xb_item2 = _.find xb_items, (item) -> item.status is '已完成'
              #if xb_item and xb_items.length > 1
              #  console.log xb_item, 'xb_item'
              #  fsk_department.items = fsk_department.items.remove xb_item
              #if xb_item2
              #  xb_item2._id = '300000000000000000000005'
              #  xb_item2.name = '胸部'
              #  images = record.images.filter (image) -> image.tag.match /胸部/
              #  for image in images
              #    image.tag = '放射科:胸部'
              #  xb_item2.description = images?[0]?.detail
              #  # 胸部正位像心肺未见异常。
              #  # 两侧胸廓对称，骨质未见异常。两侧肺野清晰，未见实质病变；两肺门及纵隔影无增大；双膈面\n光整，双侧肋膈角清晰锐利；心影大小在正常范围。
              #  console.log fsk_department.items
              #for item in fsk_department.items
              #if item._id.toString() is '300000000000000000000005'
              # item.name = '胸部'
              #else if item._id.toString() is '300000000000000000000007'
              # item.name = '腰椎'
              #else if item._id.toString() is '300000000000000000000001'
              # item.name = '颈椎'
          console.log record.barcode, 'barcode'
          record.mark_update2 = on
          record.save callback
    console.log tasks.length
    async.series tasks, (error) ->
      console.log if error then error else '成功'
      process.exit()
