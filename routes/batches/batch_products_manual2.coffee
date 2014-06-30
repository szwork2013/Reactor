moment = require "moment"
_      = require "underscore"
pinyin = require '../../utils/pinyin.coffee'

app.get '/batches/:batch_id/configurations_brochure2', (req, res) ->
  {Batch, Product, Department, User} = req.models
  {batch_id} = req.params
  Batch.findOne({_id: batch_id})
  .exec (error, batch) ->
    return res.send error.stack if error
    return res.send 404 unless batch
    # 暂时这样处理，由于先前的bug导致有许多注册的批次没有注册人
    user_id = batch.registration?._id or '4e5bb37258200ed9aabc5d90'
    User.id user_id, (error, user) ->
      return res.send error.stack if error
      return res.send 404 unless user
      Product.findOne({batch: batch_id})
      .select('configurations.discount_price configurations._id configurations.name')
      .select('configurations.items configurations.combos configurations.price')
      .exec (error, product) ->
        return res.send error.stack if error
        return res.send 404 unless product
        product = product.toJSON()
        items  = []
        combos = []
        small_package = []
        combo_packages = {}
        for configuration in product.configurations
          configuration.index = ['男', '女'].indexOf((configuration.name?.match(/男|女/)?[0] or ''))
        product.configurations = product.configurations.sort (a, b) ->
          if a.index > b.index then 1
          else if a.index < b.index then -1
          else if a.name > b.name then 1
          else -1

        configurations = product.configurations
        for configuration in configurations
          configuration.sex = (if configuration.name.match(/男/) then '男' else if configuration.name.match(/女/) then '女' else '共通')
          pck =
            name: configuration.name
            combo_used: off
            sex: configuration.sex
          small_package.push pck
          items = items.concat configuration.items
          combos = combos.concat configuration.combos
          delete configuration.items
          for combo_id in configuration.combos
            combo_packages[combo_id] or = []
            combo_packages[combo_id].push configuration.name
        Product.find({'configurations._id': {'$in': combos}})
        .select('_id name order configurations._id configurations.sex configurations.name configurations.mean')
        .select('configurations.items configurations.price')
        .sort('order')
        .exec (error, product_combos) ->
          return res.send error.stack if error
          product_combos = product_combos.map (combo) -> combo.toJSON()
          combos = _.uniq combos.map((c_id) -> c_id.toString())
          items  = _.uniq items.map((item_id) -> item_id.toString())
          cached_items = Department.cached_items
          small_combo_price = {}
          for product_combo in product_combos
            product_combo.configurations = product_combo.configurations.filter (config) -> config._id.toString() in combos
            for configuration in product_combo.configurations
              if not configuration.packages
                configuration.packages or = JSON.parse JSON.stringify(small_package)
              pcks = combo_packages[configuration._id]
              for name in pcks
                found_pck = _.find configuration.packages, (pck) -> pck.name is name
                found_pck.combo_used = 'combo_used'
                for pck in configuration.packages
                  if configuration.sex and configuration.sex isnt pck.sex
                    pck.not_choosen = 'not_choosen'
              small_combo_price[configuration._id] = configuration.price
              configuration.items = configuration.items.filter (item_id) -> item_id.toString() in items
              configuration.items = configuration.items.map (item_id) -> cached_items[item_id]
            #product_combo.configurations = product_combo.configurations.filter (config) -> config.items.length
          #product_combos = product_combos.filter (product) -> product.configurations.length

          final_combo =
            name: '总检'
            configurations: [
              name: '总检'
              items: []
              packages: []
            ]

          for configuration in product.configurations
            configuration.market_price = configuration.combos.reduce (memo, combo_id) ->
              memo += small_combo_price[combo_id]
              memo
            , 0
            delete configuration.combos
            final_combo.configurations[0].packages.push name: configuration.name, sex: configuration.sex, combo_used: 'combo_used'
          product_combos.push final_combo
          year  = moment(batch.registration?.date_string).year()
          month = moment(batch.registration?.date_string).month()
          if (month+1) >= 10
            year = year + '-' + (year + 1)
          batch_product =
            year: year
            company: batch.company
            name: user.name
            telephone: user.telephone
            mobile: user.mobile
            email: user.email
            configurations: product.configurations
            combos_count:   combos.length
            items_count:    items.length
            product_combos: product_combos
          #res.send batch_product
          res.render 'batch_products_manual2', batch_product
