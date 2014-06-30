underscore = require 'underscore'
mongodb = require 'mongodb'
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  client.collection('products').find().toArray (err, docs) ->
    client.collection('departments').find().toArray (err, departments) ->
      for product1 in departments
        for product2 in departments
          # console.log product1.name, product1.items.map((i) -> i._id.toString())
          # console.log product2.name, product2.items.map((i) -> i._id.toString())
          # continue
          if product1 isnt product2 and underscore.intersection(product1.items.map((i) -> i._id.toString()), product2.items.map((i) -> i._id.toString())).length
            console.log "科室包含重复项目", product1.name, product2.name
      console.log "产品数量", docs.length
      combos = docs.filter (x) -> x.category is 'combo'
      combo_hash = combos.reduce ((memo, combo) ->
        memo[combo._id] = combo.items
        memo
      ), {}
      console.log "大组合数量", combos.length
      flattened_combos =  underscore.flatten underscore.pluck combos, 'configurations'
      flattened_combo_ids = underscore.pluck(flattened_combos, '_id').map (x) -> x.toString()
      console.log "小组合数量", flattened_combo_ids.length
      correct_ids = flattened_combo_ids.reduce(((memo, x) ->
        memo[x] = 1 + (memo[x] or 0)
        memo
      ), {})
      for k, v of correct_ids
        if v > 1
          # console.log k
          error_combos = flattened_combos.filter (x) -> x._id.equals k
          console.log "组合编号重复", underscore.pluck error_combos, 'name'
      # console.log flattened_combo_ids
      console.log "不重复项目数量", underscore.unique(flattened_combo_ids).length
      pkgs = docs.filter (x) -> x.category is 'package'
      for pkg in pkgs
        for configuration in pkg.configurations
          for combo in configuration.combos
            if combo.toString() not in flattened_combo_ids
              console.log "套餐中组合在组合中不存在", pkg._id, pkg.name, configuration.name, combo
      client.collection('departments').find (err, collection) ->
        collection.toArray (err, departments) ->
          sex_hash = {}
          for department in departments
            for item in department.items
              if item.sex
                # console.log item._id, item.sex, item.name
                sex_hash[item._id] = item.sex
           # console.log JSON.stringify sex_hash
           for pkg in pkgs
              for configuration in pkg.configurations
                sex = if configuration.name.match(/男/) then '男' else if configuration.name.match(/女/) then '女' else false
                for item in configuration.items
                  if sex and sex_hash[item] and sex isnt sex_hash[item]
                    console.log "套餐与项目性别不符", pkg.name, configuration.name, item
            process.exit()
