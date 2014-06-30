records = null

mongodb = require 'mongodb'
async = require 'async'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  # console.log err
  records = client.collection 'records'
  x_ray_suggestions = []
  client.collection('suggestiongroups').findOne {name:'放射科'}, (err, suggestiongroup) ->
    # console.log err if err
    # console.log "X", suggestiongroup
    for suggestion in suggestiongroup.suggestions
      for condition in suggestion.conditions
        x_ray_suggestions.push condition
    console.log JSON.stringify x_ray_suggestions
    # console.log "Z"
    records.find({}, {barcode:1}).toArray (err, res) ->
      # console.log err
      ids = res.map((x) -> x.barcode).filter (x) -> x
      console.log ids.length
      tasks = ids.map (id) ->
        (callback) ->
          records.findOne {barcode: id}, {}, (err, doc) ->
            return callback(null, []) if doc.appeared[0] and (doc.appeared[0] < '2013-09-20')
            # console.log doc.barcode
            conditions = []
            for d in doc.departments
              for i in d.items
                # console.log i.value if i.name is '心率'
                if d.name in ['生化检验', '无机盐', '免疫检验'] and (i.value > i.ut * 5 or i.value < 0)
                  conditions.push d.name + '|' + i.name + '|' + doc.profile.source + '|' + id + '|' + doc.profile.sex + '|' + i.name + '|' + i.value + '|' + i.ut
                for c in i.conditions
                  # console.log doc.profile.source
                  conditions.push d.name + '|' + i.name + '|' + doc.profile.source + '|' + id + '|' + doc.profile.sex + '|' + c.detail if c.name is "其他" # or (i.name is '颈动脉' and '2013-10-15' in doc.appeared)
                if i.name.match /片$/
                  for c in i.conditions
                    if c.name not in x_ray_suggestions
                      conditions.push d.name + '|' + i.name + '|' + doc.profile.source + '|' + id + '|' + doc.profile.sex + "|" + c.name + "|无建议"
            # console.log doc.departments.some((d) -> d.items.some((i) -> i.name.match(/肝/) and i.conditions.some((c) -> c.name.match /切除/)))
            # console.log doc.departments.some((d) -> d.items.some((i) -> i.name.match(/肝/) and i.normal))
            if doc.departments.some((d) -> d.items.some((i) -> i.name.match(/肝/) and i.conditions.some((c) -> c.name.match(/切/)))) and doc.departments.some((d) -> d.items.some((i) -> i.name.match(/肝/) and i.normal))
              conditions.push id + '|' + '肝脏切除术后矛盾_类型A'
            if doc.departments.some((d) -> d.items.some((i) -> i.name is '子宫附件' and i.conditions.some((c) -> c.name.match(/子宫.*切/)))) and doc.departments.some((d) -> d.items.some((i) -> i.name is '子宫' and i.normal))
              conditions.push id + '|' + '子宫切除术后矛盾_类型A'
            if doc.departments.some((d) -> d.items.some((i) -> i.name is '子宫' and i.conditions.some((c) -> c.name.match /子宫.*切/))) and doc.departments.some((d) -> d.items.some((i) -> d.name is '腹部彩超' and i.name is '子宫附件' and i.normal))
              conditions.push id + '|' + '子宫切除术后矛盾_类型B'
            # if doc.departments.some((d) -> d.items.some((i) -> i.name is '子宫' and i.conditions.some((c) -> c.name is '子宫切除术后'))) and doc.departments.some((d) -> d.items.some((i) -> i.name is '子宫附件' and i.normal))
              # conditions.push id + '|' + '子宫切除术后删除附件'
            if doc.departments.some((d) -> d.items.some((i) -> i.conditions.some((c) -> c.name.match /胆囊.*切/))) and doc.departments.some((d) -> d.items.some((i) -> (d.name is "腹部彩超" and i.name.match(/胆/) and i.normal) or (d.status isnt '放弃' and d.name is '内科' and i.name is '病史' and not i.conditions.some((c) -> c.name.match /胆囊.*切/)  )  ))
              conditions.push id + '|' + '胆囊切除术后矛盾_类型A'

            callback null, conditions
      async.series tasks, (err, res) ->
        result = []
        for i in res
          for c in i
            result.push c
        result = result.sort (a, b) -> if a > b then 1 else -1
        console.log c for c in result
        console.log "完成"
        process.exit()
