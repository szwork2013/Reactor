render_profile = (barcode) ->
  $.get "/records/#{barcode}?fields=profile.basic", (record) ->
    $('.name').html(record.profile.basic.name)
    $('.sex').html(if record.profile.basic.sex is 'male' then '男' else '女')
    $('.age').html(record.profile.basic.age)

render_departments = (barcode) ->
  $.get "/records/#{barcode}/status", (departments) ->
    content = []
    departments = departments.filter (d) -> 
      d.status in  ['未完成', '未采样', '待检验', '放弃', '延期'] and d.name not in ['尿常规', '便潜血', '便隐血']
    console.log departments, 'departments'
    for d in departments
      # 修改名称
      if d.name.match /(宫颈.*细胞学|TCT)/
        d.name = 'TCT标本'
      else if d.name.match /宫颈刮片/
        d.name = '宫颈刮片标本'
      else if d.name.match /白带常规/
        d.name = '白带常规标本'
      # 合并采血科室
      if d.category is 'laboratory' and (d.required_samplings?.some (s) -> s.match /采血/)
        d.room_id = '000000000000000000000001'
        d.name = '采血'
      else
        d.room_id = d._id
    rooms = _.groupBy departments, (d) -> d.room_id
    content = for room_id, departments of rooms
      c = {}
      ids = departments.reduce (memo,d) ->
        memo.push d._id
        memo
      , []
      c._id = ids.join(',')
      c.room_id = room_id
      c.name = departments[0].name
      if (departments.some (d) -> d.status in ['未完成', '未采样', '待检验'])
        c.status = 'incomplete'
        c.index = 1 
      else if (departments.some (d) -> d.status is '放弃')
        c.status = 'giveup'
        c.index = 2 
      else if (departments.some (d) -> d.status is '延期')
        c.status = 'reschedule'
        c.index = 3 
      c
    content = _.sortBy content, (item) -> item.index
    $('ul').html(Mustache.render($('#template').html(), content))
    if content.length <= 6
      $('ul').addClass('status1')
    else
      $('ul').addClass('status2')
    events_bind barcode

events_bind = (barcode) ->
  actions = {'giveup': 'reschedule', 'reschedule': 'giveup', 'incomplete': 'giveup'}
  $("li").click (event) ->
    event.stopPropagation()
    id = $(@).attr('_id')
    status = actions[$(@).attr('class')]
    $.ajax
      type: 'POST'
      url: "records/#{barcode}/departments/#{id}/#{status}"
      success: (result) =>
        $(@).attr('class', status)
  hammer = new Hammer($("ul")[0])
  hammer.ondragstart = (event) ->
    ids = []
    $("li.incomplete").each () ->
      ids.push $(this).attr('_id')
    ids = ids.join(',') or ''
    directions = {'right': 'giveup', 'left': 'reschedule'}
    if ids
      $.ajax
        type: 'POST'
        url: "records/#{barcode}/departments/#{directions[event.direction]}?departments=#{ids}"
        success: (result) ->
          $("li.incomplete").attr('class', directions[event.direction])
        
render_record = (barcode) ->
  render_profile barcode
  render_departments barcode

barcode.regist /\d{8}/, render_record
