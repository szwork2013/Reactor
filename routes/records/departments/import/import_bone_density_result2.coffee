app.get '/records/:barcode/departments/bone_density2/:io', (req, res) ->
  {Record, Department} = req.models
  {barcode} = req.params
  
  Record.findOne({barcode: barcode})
  .select('profile')
  .exec (error, record) ->
    return res.send 500, error.stack if error
    return res.send 404, '未找到档案' unless record
    #[sos, bua] = req.body.data.split '|'
    {sex, age} = record.profile
    #value = (0.25 * sos + 0.5 * bua - 310).toFixed(2)
    value = req.params.io
    value_json =
      OI: value
      OI1: references[sex]['ut']
      OI2: references[sex]['lt']
      Z: ((value/references[sex][age])*100).toFixed(2)
      T: ((value/references[sex]['20'])*100).toFixed(2)
    original_department = Department.clone '超声骨密度'
    original_item = original_department.items_hash['超声骨密度']
    item =
      _id: original_item._id
      name: '超声骨密度'
      category: original_item.category
      value: JSON.stringify value_json
    if value > references[sex]['ut']
      item.normal = original_item.default
      item.conditions = []
    else if value < references[sex]['ut'] and value > references[sex]['lt']
      item.conditions = original_item.conditions.filter (result) -> result.name is '骨质减少'
    else if value < references[sex]['lt']
      item.conditions = original_item.conditions.filter (result) -> result.name is '骨质疏松'
      # console.log item
    single_record_entries =
      barcode: barcode
      entries: [item]
    Record.import_single_record_entries single_record_entries, '超声骨密度', '周荔'
    , (error, according_items) ->
      return res.send 500, error.stack if error
      res.send {}

references =
  男:
    'ut': 48.88
    'lt': 41.38
    '20': 53.88
    '21': 53.88
    '22': 53.67
    '23': 53.63
    '24': 53.52
    '25': 53.49
    '26': 53.42
    '27': 53.34
    '28': 53.33
    '29': 53.30
    '30': 53.25
    '31': 53.18
    '32': 53.09
    '33': 52.98
    '34': 52.86
    '35': 52.71
    '36': 52.55
    '37': 52.38
    '38': 52.19
    '39': 51.99
    '40': 51.77
    '41': 51.54
    '42': 51.30
    '43': 51.05
    '44': 50.79
    '45': 50.52
    '46': 50.24
    '47': 49.96
    '48': 49.67
    '49': 49.37
    '50': 49.07
    '51': 48.77
    '52': 48.46
    '53': 48.15
    '54': 47.83
    '55': 47.52
    '56': 47.21
    '57': 46.90
    '58': 46.59
    '59': 46.28
    '60': 45.98
    '61': 45.68
    '62': 45.38
    '63': 45.09
    '64': 44.81
    '65': 44.54
    '66': 44.27
    '67': 44.01
    '68': 43.77
    '69': 43.53
    '70': 43.30
    '71': 43.09
    '72': 42.89
    '73': 42.71
    '74': 42.54
    '75': 42.38
    '76': 42.24
    '77': 42.12
    '78': 42.02
    '79': 41.93
    '80': 41.87
    '81': 41.77
    '82': 41.67
    '83': 41.57
    '84': 41.47
    '85': 41.37
    '86': 41.27
    '87': 41.17
    '88': 41.07
    '89': 40.97
    '90': 40.87
    '91': 40.77
    '92': 40.67
    '93': 40.57
    '94': 40.47
    '95': 40.37
    '96': 40.27
    '97': 40.17
    '98': 40.07
    '99': 39.97
    '100': 39.87

  女:
    'ut': 44.68
    'lt': 37.18
    '20': 49.68
    '21': 49.63
    '22': 49.55
    '23': 49.47
    '24': 49.36
    '25': 49.25
    '26': 49.11
    '27': 48.96
    '28': 48.80
    '29': 48.63
    '30': 48.44
    '31': 48.24
    '32': 48.03
    '33': 47.81
    '34': 47.58
    '35': 47.34
    '36': 47.09
    '37': 46.83
    '38': 46.56
    '39': 46.29
    '40': 46.00
    '41': 45.71
    '42': 45.42
    '43': 45.12
    '44': 44.81
    '45': 44.50
    '46': 44.18
    '47': 43.87
    '48': 43.54
    '49': 43.22
    '50': 42.89
    '51': 42.57
    '52': 42.24
    '53': 41.91
    '54': 41.58
    '55': 41.25
    '56': 40.93
    '57': 40.60
    '58': 40.28
    '59': 39.96
    '60': 39.64
    '61': 39.33
    '62': 39.02
    '63': 38.72
    '64': 38.42
    '65': 38.13
    '66': 37.85
    '67': 37.57
    '68': 37.30
    '69': 37.04
    '70': 36.79
    '71': 36.54
    '72': 36.31
    '73': 36.08
    '74': 35.87
    '75': 35.67
    '76': 35.48
    '77': 35.30
    '78': 35.14
    '79': 34.99
    '80': 34.85
    '81': 34.65
    '82': 34.45
    '83': 34.25
    '84': 34.05
    '85': 33.85
    '86': 33.65
    '87': 33.45
    '88': 33.25
    '89': 33.05
    '90': 32.85
    '91': 32.65
    '92': 32.45
    '93': 32.25
    '94': 32.05
    '95': 31.85
    '96': 31.65
    '97': 31.45
    '98': 31.25
    '99': 31.05
    '100': 30.85
