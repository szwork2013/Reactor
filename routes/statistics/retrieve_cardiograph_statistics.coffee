moment  = require "moment"

app.get '/daily_cardiograph_statistics/:date', authorize('doctor', 'admin'), (req, res) ->
  {Record} = req.models
  {date}   = req.params
  commands = []
  commands.push
    '$match':
      'samplings.sampled.date_string': date
  commands.push
    '$unwind': '$samplings'
  commands.push
    '$unwind': '$departments'
  commands.push
    '$match':
      'samplings.sampled.date_string': date
      'samplings.name': '心电图'
      'departments.name': '心电图'
  commands.push
    '$project':
      'departments.name': 1
      'departments.status': 1
      'samplings.name': 1
      'images': 1
      'profile.name': 1
      'profile.sex': 1
      'profile.age': 1
      'barcode': 1
  Record.aggregate commands,(error, results) ->
    return res.send 500, error.stack if error
    result =
      sampled: []
      hasnt_images: []
      hasnt_results: []
    for data in results
      record =
        barcode: data.barcode
        name:    data.profile.name
        sex:     data.profile.sex
        age:     data.profile.age
      result.sampled.push record
      if not data.images.filter((image) -> image.tag is '心电图').length
        result.hasnt_images.push record
      if data.departments.status isnt '已完成'
        result.hasnt_results.push record
    res.send result
