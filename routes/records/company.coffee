
moment  = require 'moment'
moment.lang('zh-cn')
_       = require 'underscore'
barcode = require '../../utils/barcode.coffee'

app.get '/records/profile/:source', authorize('cashier', 'admin'), (req, res) ->
  {Record} = req.models
  Record.find({'profile.source': req.params.source})
  .select('barcode profile')
  .exec (error, records) ->
    return res.send 500, error.stack if error
    cards = []
    records = records.filter (record) -> record.profile.division in ['北京分院家属', '北京分院聘用', '科发局聘用', '学部局聘用']
    # records = records.filter (record) -> record.barcode in [
    #   '10009400'
    #   '10006787'
    #   '10006583'
    #   '10006739'
    #   '10006786'
    #   '10006698'
    #   '10006742'
    #   '10006716'
    #   '10007182'
    # ]
    for record in records
      cards.push
        name: record.profile.name
        sex: record.profile.sex
        age: record.profile.age
        division: record.profile.division
        staff: (record.profile.notes?[0]?.match(/员工编号[:：](.*)/)?[1] or '')
        barcode: barcode {code: record.barcode, crc: off}, 'int25'
        py:  record.profile.name_pinyin?[0][0] + record.profile.name[0]
    cards = cards.sort (a, b) ->
      if a.division > b.division then -1 \
      else if a.division < b.division then 1 \
      else if a.py > b.py then 1 \
      else -1
    res.render 'guests', {cards: cards}
