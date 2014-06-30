_      = require "underscore"
pinyin = require '../../utils/pinyin.coffee'

app.get '/product_manual', (req, res) ->
  {Product, Department} = req.models
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "X-Requested-With")
  Department.find()
  .select('name category order items._id items.name items.sex')
  .exec (error, departments) ->
    return res.send error.stack if error
    departments = departments.sort (a, b) ->
      if a.category > b.category then 1 \
      else if a.category < b.category then -1 \
      else if a.order > b.order then 1 \
      else -1
    items = {}
    for department  in departments
      for item in department.items
        items[item._id] = item
    rooms = []
    yibanqingkuan = departments.filter (d) -> d.name in ['身高体重','血压','腰臀比','体脂率']
    rooms.push name: '一般检查', category: 'clinic', departments: yibanqingkuan
    lcjc = departments.filter (d) -> d.name in ['内科', '外科', '眼科', '耳鼻喉科', '口腔科', '妇科', '心电图']
    rooms.push name: '临床检查', category: 'clinic', departments: lcjc
    csyxjc = departments.filter (d) -> d.name in ['腹部彩超','颈部彩超', '乳腺彩超']
    rooms.push name: '超声影像检查', category: 'clinic', departments: csyxjc
    rooms.push name: '放射学检查', category: 'clinic', departments: departments.filter((d) -> d.name is '放射科')
    rooms.push name: '骨密度检测', category: 'clinic', departments: departments.filter((d) -> d.name is '骨密度')
    lcjy = departments.filter (d) -> d.name in ['血常规','血型','尿常规','便潜血','全血微量元素','血流变', '人乳头瘤病毒','宫颈超薄细胞学检查','宫颈刮片']
    rooms.push name: '临床检验', category: 'laboratory', departments: lcjy
    rooms.push name: '消化系统检测', category: 'laboratory', departments: departments.filter((d) -> d.name is 'C13幽门螺旋杆菌检测')
    rooms.push name: '生化检验', category: 'laboratory', departments: departments.filter((d) -> d.name in ['生化检验', '无机盐'])
    rooms.push name: '免疫检验', category: 'laboratory', departments: departments.filter((d) -> d.name is '免疫检验')
    Product.find()
    .select('name price configurations.name configurations.items configurations.sex')
    .select('configurations._id configurations.price configurations.mean')
    .select('configurations.results')
    .where('category').equals('combo')
    .sort('order')
    .exec (error, combos) ->
      return res.send 500, error.stack if error
      Product.find({batch: {'$exists': false}})
      .where('category').equals('package')
      .select('name target mean price configurations.name configurations.items')
      .select('configurations._id configurations.price configurations.combos configurations.sex')
      .sort('order')
      .exec (error, packages) ->
        return res.send 500, error.stack if error
        packages = packages.map (p) -> p.toJSON()
        combos = combos.map (c) -> c.toJSON()
        big_combos = {} # 大组合编号对应名称
        small_combos = {} # 小组合编号对应名称
        small_combo_price = {} # 小组合编号对应价格
        small_big_ids = {} # 小组合编号对应大组合编号
        conditions_combos = [] # 症状对应的组合
        for combo in combos
          big_combos[combo._id] = combo.name
          for configu in combo.configurations
            small_combo_price[configu._id] = configu.price
            small_big_ids[configu._id] = combo._id.toString()
            small_combos[configu._id] = configu.name unless configu.sex
            small_combos[configu._id] = name: configu.name
            small_combos[configu._id]['sex'] = configu.sex if configu.sex
            configu.items = configu.items.map((item) -> items[item]).filter (item) -> item
            for result in configu.results
              found_condition = _.find conditions_combos, (c) -> c.name is result
              if found_condition and configu.name not in found_condition?.combos
                found_condition.combos.push configu.name
              else if not found_condition
                conditions_combos.push name: result, py: pinyin(result)[0][0], combos: [configu.name]

        # 小组合编号对应所使用过的大套餐名称数组
        #big_package_names  = {}
        item_package_names = {}
        for p in packages
          small_combos_ids = []
          big_combos_ids = []
          for configuration in p.configurations
            configuration.market_price = configuration.combos.reduce (memo, combo_id) ->
              memo += small_combo_price[combo_id]
              memo
            , 0
            for item_id in configuration.items
              item_package_names[item_id] = [] unless item_package_names[item_id]
              item_package_names[item_id].push p.name if p.name not in item_package_names[item_id]

            for combo_id in configuration.combos
              #big_package_names[combo_id] = [] unless big_package_names[combo_id]
              #big_package_names[combo_id].push p.name if p.name not in big_package_names[combo_id]
              big_combo_id = small_big_ids[combo_id]
              big_combos_ids.push big_combo_id if big_combo_id and big_combo_id not in big_combos_ids
              small_combos_ids.push combo_id if combo_id not in small_combos_ids
            delete configuration.combos
            delete configuration.items
            delete configuration.sex
          p.combos = []
          for b_id in big_combos_ids
            combo =
              name: big_combos?[b_id]
              small_combos: []
            for s_id in small_combos_ids
              combo.small_combos.push small_combos?[s_id] if small_big_ids?[s_id] is b_id and not combo.small_combos.some((c) -> c.name is small_combos?[s_id].name)
            p.combos.push combo
        
        for combo in combos
          for configu in combo.configurations
            #configu.package_names = big_package_names[configu._id]
            package_names = []
            for item in configu.items
              package_names.push item_package_names[item._id]
            configu.package_names = _.intersection package_names...

        res.send
          conditions_combos: conditions_combos.sort((a, b) -> if a.py > b.py then 1 else -1)
          departments: rooms
          combos: combos
          packages: packages
 
