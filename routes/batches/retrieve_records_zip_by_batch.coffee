{exec}   = require 'child_process'
async    = require "async"

app.get '/batches2/:company/:file_name', authorize('mo', 'admin'), (req, res) ->
  {company, file_name} = req.params
  company   = decodeURI company
  file_name = decodeURI file_name
  return res.send 403 unless file_name.match /\.zip/
  {Batch, Record} = req.models
  Batch.find(company: company)
  .sort('-_id')
  .limit(1)
  .exec (err, batches) ->
    return res.send 500, err.stack if err
    Record.find({'profile.batch': batches[0]._id, status: {'$in': ['已完成', '已打印']}})
    .select('_id status appeared profile barcode non_empty')
    .exec (err, records) ->
      return res.send 500, err.stack if err
      exec "rm -rf ./public/zips/#{company}", (error) ->
        return res.send 500, error if error
        exec "mkdir ./public/zips/#{company}", (error) ->
          return res.send 500, error if error
          records = records.filter (r) -> r.non_empty
          tasks   = records.map (record) ->
            (callback) ->
              exec "cp ./public/pdfs/reports/#{record.barcode}.pdf ./public/zips/#{company}/#{(record.profile.division?.trim() or '其他部门').replace(/[\(\)\（\）]/g, '').replace(/\s/g, '').trim()}_#{record.profile.name.replace(/'/g, "").trim()}_#{record.barcode}.pdf", (error) ->
                callback()
          async.parallelLimit tasks, 10, (error) ->
            return res.send 500, error if error
            exec "zip -j ./public/zips/#{file_name} ./public/zips/#{company}/*", (error) ->
              res.send 500, error if error
              exec "rm -rf ./public/zips/#{company}", (error) ->
                return res.send 500, error if error
                res.set('Content-Type', 'application/zip')
                res.set('Content-Disposition', "attachment; filename=#{file_name}")
                res.end("./public/zips/#{file_name}")
