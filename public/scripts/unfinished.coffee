exports = this
exports.sort_data_key = ['今天','昨天','前天','七天内','半个月内','一个月内','更早']
hashValue = decodeURI(window.location.hash);

#如果是特殊url提供无测试数据
check_test = (data) ->
  if hashValue? && hashValue is '#notest'
    fdata = _.reject data, (num) ->
      (num.profile.name).indexOf('测试') isnt -1
    data=fdata
  return data

#判断是否需要打印客户barcode
check_show_barcode = () ->
  if hashValue? && hashValue is '#barcode' then return 1
  else return 0


#绑定延期、未完成tab标签切换
bind_tabclick = () ->
  $('#tab').find('div').each () ->
    $(@).bind 'click', () -> 
      if $(@).attr('id') is 'tab_a'
        $('#tab_a').addClass('tab_checked').removeClass('tab_init')
        $('#tab_b').addClass('tab_init').removeClass('tab_checked')
        $('#unfinishDiv').hide()
        $('#delayDiv').show()
      else
        #ajax_getdata '/need_check_records', []
        $('#tab_b').addClass('tab_checked').removeClass('tab_init')
        $('#tab_a').addClass('tab_init').removeClass('tab_checked')
        $('#delayDiv').hide()
        $('#unfinishDiv').show()

#请求数据-（以下注释为线上测试数据）
ajax_getdata = (url, param) ->
  $.ajax
    type: 'get'
    url: url
    data: param
    success: (data) ->
      console.log data
      cdata = check_test data
      check_data cdata
    error: (error)->
      console.log error
  #以下注释为线下测试数据，
  #cdata = check_test list_data
  #check_data cdata

#筛选未完成、延期数据
check_data = (tab_data) ->
  unfinished_arr=[]
  schedule_arr=[]
  $.each tab_data, (index, value) ->
    unfinished_arr.push value if value.unfinished_departments.length isnt 0
    schedule_arr.push value if value.schedule_departments.length isnt 0
  
  #按相对时间分组
  schedule_group_arr = group_data schedule_arr
  unfinished_group_arr = group_data unfinished_arr
  #创建dom
  create_tab schedule_group_arr, 'delayTab', 'schedule_departments', 'schedule_items'
  create_tab unfinished_group_arr, 'unfinishTab', 'unfinished_departments', 'unfinished_items'
  bind_listview_row()

#获得当前时间
get_today = (format) ->
  yy = new Date().getFullYear()
  mm = if (new Date().getMonth()+1) < 10 then "0#{new Date().getMonth()+1}" else new Date().getMonth()+1
  dd = if (new Date().getDate()) < 10 then "0#{new Date().getDate()}" else new Date().getDate()
  if format?
    switch format
      when 'yyyy/mm/dd' then "#{yy}/#{mm}/#{dd}"
  else
    return "#{yy}-#{mm}-#{dd}"

#日期格式化并排序
formate_date = (date_arr) ->
  date_arr.replace(/^(\d{4})[-](\d{2})[-](\d{2})$/,"$1-$2") if date_arr?

#日期转换毫秒
rems_date = (date) ->
  if date?
    d = date.replace(/^(\d{4})[-](\d{2})[-](\d{2})$/,"$1/$2/$3");
    return (new Date("#{d} 00:00:00")).getTime();

#集合按规则分组
group_data = (data) ->
  mstoday = (new Date("#{get_today('yyyy/mm/dd')} 00:00:00")).getTime() 
  garr = _.groupBy data, (num) ->
    console.log num
    td = rems_date(num.appeared[num.appeared.length-1])
    if td >= mstoday then exports.sort_data_key[0]
    else if td >= mstoday-86400000 then exports.sort_data_key[1]
    else if td >= mstoday-86400000*2 then exports.sort_data_key[2]
    else if td >= mstoday-86400000*7 then exports.sort_data_key[3]
    else if td >= mstoday-86400000*15 then exports.sort_data_key[4]
    else if td >= mstoday-86400000*30 then exports.sort_data_key[5]
    else exports.sort_data_key[6]
  #console.log garr
#根据数据创建表格
create_tab = (data, id, type, depItem) ->
  texthtml = ""
  udata_html = ""
  count=0
  uago_num=0
  #清空节点
  $("##{id} >li").remove()

  #判断生成html是否有特殊需要（比如需要打印出用户barcode）
  vip_type = check_show_barcode()

  #处理延期
  for index in exports.sort_data_key
    continue if !data[index]?
    items = data[index]
    texthtml += "<li class='wk title' data-role='list-divider'> #{index} <span class='ui-li-count'>#{items.length}</span></li>"
    #排序（先按日期，再按编号）
    dateSort = _.sortBy items, (num) ->
      return num.appeared[num.appeared.length-1]
    gp = _.groupBy dateSort, (t) ->
      return t.appeared[t.appeared.length-1]
    sb = _.map gp, (num, key) ->
       _.sortBy num, (i) ->
         return i.barcode
    sortArr = _.reduceRight sb, ((a, b) -> return b.concat a),[]

    for item, idx in sortArr
      ids_arr = _.map item[type], (num, key) ->
        return num.ids
      ids_str = ids_arr.join(',')
      texthtml += "<li class='wk contextline content_li' data-giveupurl='/records/#{item.barcode}/departments/#{ids_str}/giveup' data-delayurl='/records/#{item.barcode}/departments/#{ids_str}/reschedule'>"
      texthtml += "<div>"
      texthtml += """
      <div><span>#{item.appeared[item.appeared.length-1]}</span>
      <span>#{item.profile.name}</span>
      <span>#{item.profile.sex}</span>
      <span>#{item.profile.age}</span>"""
      texthtml += "<span>#{item.barcode}</span>" if vip_type is 1
      texthtml += "</div>"
      texthtml += "<div>#{item.profile.source}</div>"
      texthtml += "<div>"
      texthtml += "<p class='departmentDetails'>"
      #科室循环
      for department in item[type]
        dtext=''
        if department[depItem]? && department[depItem].length isnt 0
          depItemName = []
          for di in department[depItem]
            depItemName.push di
          dtext = " (#{depItemName.join('，')})"
        texthtml += "<span>#{department.name+dtext}</span>"
      texthtml += "</p>"
      texthtml += "</div>"
      #texthtml += "<span style='position: absolute;right: 10px;top: 20px;'>#{if item.profile.tel? then item.profile.tel else ''}</span>"
      texthtml += "<a href='tel:#{item.profile.tel}'> </a>" if item.profile.tel?
      texthtml += "</li>"
  texthtml += "<li class='refresh_li'>刷新</li>"
  texthtml += "<li style='height:150px;background:#F0F0F0;'></li>"
  $("##{id}").append(texthtml)
  $("##{id}").listview("refresh")

#延期 放弃 左右按钮（btnClass: 'rightSwipeBtn'-样式名）
#为listview每行绑定事件
bind_listview_row = () ->
  #$("#unfinishTab").find('li').bind 'swiperight', ->
  $('#unfinishTab li.contextline').swipeDelete 
    direction: 'swiperight',
    btnTheme: 'a'
    btnLabel: '延期'
    btnClass: 'rightSwipeBtn'
    click: (e) ->
      li = $(@).parent()
      $(li).css('background','#68BEE1')
      url = $(li).attr('data-delayurl')
      changeStatus url, li
      return false

  $('#unfinishTab li.contextline').swipeDelete 
    direction: 'swipeleft',
    btnTheme: 'a'
    btnLabel: '放弃'
    btnClass: 'leftSwipeBtn'
    click: (e) ->
      li = $(@).parent()
      $(li).css('background','#F06C70')
      url = $(li).attr('data-giveupurl')
      changeStatus url, li
      return false
      
  $('#delayTab li.contextline').swipeDelete 
    direction: 'swipeleft',
    btnTheme: 'a'
    btnLabel: '放弃'
    btnClass: 'leftSwipeBtn'
    click: (e) ->
      li = $(@).parent()
      $(li).css('background','red')
      url = $(li).attr('data-giveupurl')
      changeStatus url, li
      return false
  
  #刷新按钮
  $('.refresh_li').click () ->
    ajax_getdata '/need_check_records', []

  $('#hook').hook
    reloadPage: false
    textRequired: true
    loaderText: 'refresh...'
    reloadEl: () ->
      ajax_getdata '/need_check_records', []

#递归计算操作的标题节点
jq_prev_find = (dom, prop, findclass) ->
  return dom if $(dom).attr(prop) is findclass
  jq_prev_find $(dom).prev(), prop, findclass


#删除或延期
changeStatus = (url, dom) ->
  $.ajax
    type: 'post'
    data: []
    url: url
    success: (result) ->
      #删除延期与api通信成功后的节点操作
      titleDom = jq_prev_find dom, 'data-role', 'list-divider'
      liCount = parseInt($(titleDom).find('.ui-li-count').text())
      liCount = liCount-1
      if liCount < 1
        $(titleDom).remove()
      else
        $(titleDom).find('.ui-li-count').text(liCount)
      $(dom).remove()
    error: (error)->
      alert('网络异常操作失败')

#页面初始化
$ ->
  bind_tabclick()
  $('#tab_b').trigger('click')
  ajax_getdata '/need_check_records', []



#实现listview每行左右拖拽按钮
(($) ->
  $.fn.swipeDelete = (o) ->
    $(this).attr "data-swipeurl", "" #setting data-swipeurl on the li --Added: 2012/12/15
    o = $.extend({}, $.fn.swipeDelete.defaults, o)
    @filter("[data-swipeurl]").each (i, el) ->
      $e = $(el)
      $parent = $(el).parent("ul")
      $e.on o.direction, (e) ->
        
        # reference the current item
        $li = $(this)
        cnt = $(".ui-btn", $li).length
        
        # remove all currently displayed buttons
        $("div.ui-btn, ." + o.btnClass, $parent).animate
          width: "toggle"
        , 200, (e) ->
          $(this).remove()

        
        # if there's an existing button we simply delete it, then stop
        unless cnt
          
          # create button
          forword = (if o.direction is "swiperight" then "rightSwipeBtn" else "leftSwipeBtn")
          to_url = (if o.direction is "swiperight" then "delayurl" else "giveup_url")
          
          #console.log(to_url);
          $swipeBtn = $("<a>" + o.btnLabel + "</a>").attr(
            "data-role": "button"
            "data-mini": true
            "data-inline": "true"
            class: (if (o.btnClass is forword) then o.btnClass else o.btnClass + forword)
            "data-theme": o.btnTheme
            href: $li.data("")
          ).on("click tap", o.click)
          
          # slide insert button into list item
          $swipeBtn.prependTo($li).button()
          $li.find(".ui-btn").hide().animate
            width: "toggle"
          , 200
          
          # override row click
          $("div a:not(" + o.btnClass + ")", $li).on "click.swipe", (e) ->
            e.stopPropagation()
            e.preventDefault()
            $(this).off "click.swipe"
            $li.removeClass("ui-btn-active").find("div.ui-btn").remove()

  $.fn.swipeDelete.defaults =
    direction: "swiperight"
    btnLabel: "Delete"
    btnTheme: "e"
    btnClass: "rightSwipeBtn"
    click: (e) ->
      e.preventDefault()
      $(this).parents("li").slideUp()
) jQuery

