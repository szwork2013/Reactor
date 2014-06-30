_       = require "underscore"
request = require "superagent"
async   = require "async"

app.get '/batches/:batch/ygwx_results', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  {batch} = req.params
  Record.find({'profile.batch': batch, 'non_empty': on})
  .select('barcode')
  .sort('barcode')
  #  .limit(1000)
  .exec (error, records) ->
    console.log error if error
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length
    records = []
    items   = []
    titles = ['编号', '姓名', '性别', '年龄', '部门']
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.findOne({'barcode': barcode})
        .select('appeared profile barcode departments')
        .exec (error, record) ->
          return console.log error if error
          return callback() if not record.profile.name.match(/(测试|盛保善)/) and not record.profile.division?.match(/自费/)
          for department in record.departments
            for item in department.items
              if item.name.match(/乙肝/)
                name = department.name + '|' + item.name
                console.log name , 'name'
                if name not in items
                  items.push name
                  items.push '提示' if department.category is "laboratory"
          records.push record
          callback()
    async.parallelLimit tasks, 1000, (error) ->
      console.log if error then error else '成功'
      titles = titles.concat items
      datas = [titles]
      for record in records
        people = [
          record.barcode
          record.profile.name
          record.profile.sex
          record.profile.age or ''
          record.profile.division
        ]
        for department in record.departments
          conditions = []
          for item in department.items
            if item.name.match(/乙肝/)
              items = []
              for condition in item.conditions
                name = condition.summary or condition.name
                items.push name
              #if department.category is 'laboratory' and item.conditions.length
              if department.category is 'laboratory'
                people[titles.indexOf(department.name + '|' + item.name)] = item.value
                people[titles.indexOf(department.name + '|' + item.name) + 1] = items.join('，')
              else
                people[titles.indexOf(department.name + '|' + item.name)] = items.join('，') #or item.normal # items.join('，')
        datas.push people
      results = []
      for data in datas
        result = []
        for a in data
          result.push(a or '')
        for i in [0..(300 - result.length)]
          result.push ''
        results.push result
      console.log 1111111111
      start = (new Date).valueOf()
      console.log results, 'results'
      request.post("http://kells.cloudapp.net/convert/JsonToExcel")
      .send(JSON.stringify([{name: records[0].profile.source + '疾病清单', cells: results}]))
      .set('Content-Type', 'text/plain')
      .end (error, res2) =>
        console.log error, res2
        end = (new Date).valueOf()
        console.log end - start
        res.redirect res2.text
