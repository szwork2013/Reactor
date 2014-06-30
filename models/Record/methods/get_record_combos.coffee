_ = require 'underscore'

module.exports = (record_schema) ->
  
  record_schema.methods.get_record_combos = (cb) ->
    departments = @departments.filter (d) -> d.category is 'laboratory'
    items = departments.reduce (memo, d) ->
      for item in d.items
        memo.push item._id
      memo
    , []
    paid_package_ids = @orders?.reduce (memo, order) ->
      memo.push order._id if order.paid and order.category is 'package'
      memo
    , []
    paid_combo_ids = @orders?.reduce (memo, order) ->
      memo.push String(order._id) if order.paid and order.category is 'combo'
      memo
    , []
    commands = []
    commands.push $match:
      'category': 'combo'
    commands.push $unwind: '$configurations'
    commands.push $project:
      _id:1
      name:1
      order: 1
      'configurations._id':   '$configurations._id'
      'configurations.note':  '$configurations.note'
      'configurations.name':  '$configurations.name'
      'configurations.items': '$configurations.items'
    commands.push $unwind: '$configurations.items'
    commands.push $match:
      'configurations.items':
        '$in': items
    commands.push $group:
      _id: "$configurations.name"
      name:
        '$last':'$name'
      order:
        '$last':'$order'
      'configurations_id':
        '$last':'$configurations._id'
      'configurations_name':
        '$last':'$configurations.name'
      'configurations_note':
        '$last':'$configurations.note'
      'configurations_items':
        '$push' :
          '_id': '$configurations.items'
    commands.push $group:
      _id: "$name"
      name:
        '$last': '$name'
      order:
        '$last': '$order'
      configurations:
        '$push':
          '_id':   '$configurations_id'
          'name':  '$configurations_name'
          'items': '$configurations_items'
          'note':  '$configurations_note'
    commands.push $sort:
      order: 1
    @model('Product').aggregate commands, (error, results) =>
      return cb error if error
      commands = []
      commands.push $unwind: '$configurations'
      commands.push $match:
        'configurations._id':
          '$in': paid_package_ids or []
      commands.push $project:
        "_id": 1
        'name':1
        "configurations._id":1
        "configurations.combos": 1
      commands.push $unwind:
        '$configurations.combos'
      commands.push $project:
        'combos': '$configurations.combos'
      @model('Product').aggregate commands, (error, products) =>
        return cb error if error
        {configurations_index, combo_note} = @model('Product')
        combos = products?.reduce (memo, product) ->
          memo.push String(product.combos)
          memo
        , []
        combos_ids = combos.concat paid_combo_ids
        notes = []
        index = 0
        for result in results
          result.configurations = result.configurations.filter (c) ->
            String(c._id) in combos_ids
          configurations2 = JSON.parse JSON.stringify result.configurations
          for config in result.configurations
            item_ids = result.configurations.filter((c) -> c.name isnt config.name).map((c) -> _.pluck(c.items, '_id'))
            item_ids = _.flatten(item_ids).map (id) -> id.toString()
            if config.items.map((item) -> item._id.toString()).every((id) -> id in item_ids)
              configurations2 = configurations2.filter (c) -> c.name isnt config.name
          for config in configurations2
            config.order = configurations_index[config._id]
          result.configurations = configurations2
          result.configurations = result.configurations.sort (a, b) ->
            if a.order > b.order then 1 else -1
          for config in result.configurations
            if config.note
              index += 1
              config.name = config.name + '<sup>' + index + '</sup>'
              notes.push name: config.name, note: config.note
        cb null, {laboratory_combos: results.filter((r) -> r.configurations.length), notes: notes}
