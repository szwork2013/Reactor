_       = require "underscore"
request = require "superagent"

app.get '/zfg', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  Record.find({'profile.tel': {'$exists': true, '$ne': ''}})
  .select('appeared profile departments')
  .exec (error, records) ->
    return console.log error if error
    console.log records.length, 'length'
    titles = ['姓名', '性别', '体检日期', '电话', '脂肪肝', '胆固醇偏高', '甘油三酯偏高', '低密度脂蛋白偏高']
    datas = [titles]
    for record in records
      people =
        name: record.profile.name
        sex:  if record.profile.sex is 'male' then '男' else '女'
        check_date: record.appeared?[0] or ''
        tel: record.profile.tel
        zfg: []
        dgc: ''
        gysz: ''
        dmd: ''
      for room in record.departments
        for item in room.items
          for condition in item.conditions
            if condition.name.match /脂肪肝/
              people.zfg.push condition.name
              people.zfg.push condition._name if condition._name
            if item.name is '胆固醇' and condition.name is '偏高'
              people.dgc = item.value
            if item.name is '甘油三酯' and condition.name is '偏高'
              people.gysz = item.value
            if item.name is '低密度脂蛋白' and condition.name is '偏高'
              people.dmd = item.value
      if (people.dgc or people.gysz or people.dmd or people.zfg.length) and record.profile.tel
        datas.push [people.name, people.sex, people.check_date, people.tel, people.zfg.join(','), people.dgc, people.gysz, people.dmd]
    console.log datas, 'datas'
    request.post("http://kells.cloudapp.net/convert/JsonToExcel")
    .send(JSON.stringify([{name: '客人', cells: datas}]))
    .set('Content-Type', 'text/plain')
    .end (res2) =>
      res.redirect res2.text
