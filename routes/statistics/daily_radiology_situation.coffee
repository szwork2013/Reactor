fs = require 'fs'
_  = require 'underscore'

app.get '/daily_radiology_situation/:date', authorize('cashier'), (req, res) ->
  {date} = req.params
  {Record} = req.models
  Record.find({'field_complete.date_string': date, status: {'$in': ['已离场', '已完成']}})
  .select('departments images barcode')
  .exec (error, records) ->
    return res.send error.stack if error
    has_results_but_not_images = []
    has_images_but_not_result_or_description = []
    for record in records
      radiology = _.find record.departments, (d) -> d.name is '放射科'
      if radiology
        for item in radiology.items
          images = record.images.filter (image) -> image.tag.match(item.name)
          if images.length and (((item.normal or item.conditions.length) and not item.description) or ((not item.normal and not item.conditions.length) and item.description))
            has_images_but_not_result_or_description.push record.barcode
          else if ((item.normal or item.conditions.length) and item.description) and not images.length
            has_results_but_not_images.push record.barcode
    str = '有结果没图片：' + '<br>' + _.uniq(has_results_but_not_images).join('<br>')
    str += '<br><br>' + '有图片没诊断或x线所见：' + '<br>' + _.uniq(has_images_but_not_result_or_description).join('<br>')
    res.render 'departments', {page: '每日放射科导入情况', str: str}
