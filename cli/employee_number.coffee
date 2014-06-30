{exec} = require 'child_process'
company = process.argv[2]
mongodb = require 'mongodb'
ObjectID = mongodb.ObjectID
_ = require 'underscore'
fs = require 'fs'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  now = Date.now()
  batches = client.collection 'batches'
  records = client.collection 'records'
  batches.find(company: company).sort(_id: -1).limit(1).toArray (err, res) ->
    # console.log res[0]._id
    barcodes = fs.readFileSync(__dirname + '/../log/jg').toString()
    barcodes = barcodes.split('\n').filter((x) -> x)
    division_cnt = 1
    division_hash = {}
    division_inner = (input) ->
      if division_hash[input]
        return division_hash[input]
      else
        return division_hash[input] = division_cnt++
    division_number = (input) ->
      inner = "000" + division_inner(input)
      inner.substr inner.length - 3

    records.find({'profile.batch': res[0]._id },{_id: 1, status: 1, appeared:1, 'profile': 1, 'barcode': 1, non_empty: 1, suggestions: 1}).toArray (err, records) ->
      # for k, v of _.groupBy records, ((r) -> r.profile.division)
      #   console.log k, v.length
      # return
      total = 0
      total++ for record in records when record.appeared.length and record.profile.batch.toString() is '521ac73afd2990af49000ac1'
      # console.log total
      # return
      # console.log records.length
      # records.find({'profile.batch': res[0]._id},{_id: 1, status: 1, 'profile': 1, 'barcode': 1}).toArray (err, records) ->
      # console.log records.length
      records = records.filter((r) -> not /测试/.test r.profile.name).sort (a, b) -> if a.barcode > b.barcode then 1 else -1
      console.log "rm -rf #{company}"
      console.log "mkdir #{company}"
      blood_seq = (record) ->
        result = _.find(record.profile.notes, (note) -> note.match(/采血号|抽血号/))?.replace(/采血号[:：]?|抽血号[：:]?/, '').trim().replace(/\-/g,'_').replace(/\s/g,'') or ''
        result = result.split('_').map (x) ->
          y = '000' + x
          y.substr y.length - 3, 3
        result.join('_')
      # console.log records.length
      # #{(record.profile.division?.trim() or '其他部门').replace /[\(\)\（\）]/g, ''}
      # console.log "cp ../../reactor/public/pdfs/reports/#{record.barcode}.pdf #{company}/#{division_number (record.profile.division?.trim() or '其他部门').replace(/[\(\)\（\）]/g, '').replace(/\s/g, '').trim()}_#{record.barcode}.pdf" for record in records
      # console.log "cp ../../reactor/public/pdfs/reports/#{record.barcode}.pdf #{company}/#{(record.profile.division?.trim() or '其他部门').replace(/[\(\)\（\）]/g, '').replace(/\s/g, '').trim()}_#{record.profile.name.replace(/'/g, "").trim()}_#{record.barcode}.pdf" for record in records when record.non_empty
      extract_employee_number = (notes) ->
        note = notes.filter((note) -> note.match /员工编号/)?[0]
        note?.replace(/员工编号[:：]\s*/, '') or ''
      format_suggestions = (suggestions) ->
        result = ''
        for suggestion in suggestions
          result += "{" + suggestion.conditions.map((x) -> x.detail or x.name).join().replace(/\n/g, '').replace(/,/g, '，') + '|' + suggestion.content.replace(/\n/g, '').replace(/,/g, '，') + '}'
        result
      # console.log record.barcode + "," + record.profile.name + "," + extract_employee_number(record.profile.notes) for record in records when record.non_empty
      console.log record.barcode + "," + record.profile.name + "," + format_suggestions(record.suggestions) for record in records when record.non_empty
      # console.log "cp ../../reactor/public/pdfs/reports/#{record.barcode}.pdf #{company}/#{blood_seq record}_#{record.barcode}.pdf" for record in records
      # console.log record.barcode for record in records
      process.exit()
