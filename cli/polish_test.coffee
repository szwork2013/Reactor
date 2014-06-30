mongodb = require 'mongodb'
_ = require 'underscore'
async = require 'async'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.find({},{'barcode':1}).toArray (err, docs) ->
    barcodes = _(docs).pluck('barcode')
    # barcodes = ['10000746']
    tasks = barcodes.map (barcode) ->
      (callback) ->
        # polish
        records.findOne (barcode: barcode), (err, doc) ->
          doc.biochemistry?.audit?.user_id = doc.biochemistry?.audit?._id
          doc.biochemistry?.audit?.user_name = doc.biochemistry?.audit?.name
          delete doc.biochemistry?.audit?._id
          delete doc.biochemistry?.audit?.name

          # for sampling in doc.samplings
          #   sampling.sampled?.user_id = sampling.sampled?._id
          #   sampling.sampled?.user_name = sampling.sampled?.name
          #   delete sampling.sampled?._id
          #   delete sampling.sampled?.name

          # for department in doc.departments
          #   department.checking?.finished?.user_id = department.checking.finished?._id
          #   department.checking?.finished?.user_name = department.checking.finished?.name
          #   delete department.checking?.finished?._id
          #   delete department.checking?.finished?.name
          #  if sampling.status not in ['未采样', '已采样', '未付费', '已删除']
          # console.log barcode, sampling.name
          # callback()
            # sampling.status = (
            #   'unsampled': '未采样'
            #   'sampled': '已采样'
            #   'unpaid': '未付费'
            #   'invalid': '已删除'
            # )[sampling.status]
            # console.log 'STATUS:', barcode, sampling.name, sampling.status if sampling.status not in ['未采样', '已采样', '未付费', '已删除']
            # sampling.apps = if sampling.biochemistry then ['生化'] else []
          records.findAndModify (barcode: barcode), {}, doc, (err, res) ->
            return console.log barcode, err if err
            callback()
    async.parallelLimit tasks, 8, ->
      console.log 'FINISHED'
      process.exit()
