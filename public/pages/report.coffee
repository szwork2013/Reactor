#全局变量
##左右布局计数变量
layout_count = 1

#组合加续
group_title_continue = (group_name, word, title_name) ->
  title_name = '.change_level' unless title_name?
  $(group_name).find(title_name).each (index, value) ->
    if index isnt 0
      last_title = $($(group_name).find(title_name).get(index-1)).text()
      #判断是否上一个标题已有续，如果已有续，去除续后再进行比对，已保证同样标题出现多次都能正常加续
      num = last_title.indexOf(word)
      last_title = last_title.substr(0,num) if num > 0
      $(@).text($(@).text()+word) if $(@).text() is last_title

#标题容器中需要添加其他标题内容
title_group_add_title = (page, attr_name, replace_dom, clone_level) ->
  $(page).each (index, value) ->
    #找到页面需要复制的大标题
    if not $(@).next().find("[level=#{clone_level}]").first().hasClass(attr_name)
      if $(@).next().find('.container > div:eq(0)').attr('class') isnt 'note-title'
        title = $(@).find(".#{attr_name}").last().clone()
        since_title = $(@).next().find("[level=#{clone_level}]").first().contents()
        $(title).find(replace_dom).replaceWith(since_title)
        $(@).next().find("[level=#{clone_level}]").first().replaceWith(title)

#复制header或footer
clone_header_footer = (page, part, dom_arr) ->
  dom_arr = ['.clone'] unless dom_arr?
  header_arr = []
  $(page).find(part).each (index) ->
    if index is 0
      header_arr.push $(@).find(dom).clone() for dom in dom_arr
    else
      $(@).append(add_dom.clone()) for add_dom in header_arr

#处理总检要求每页最后一条实线和除第一条标题下的实线
summary_special = (page, dom_class) ->
  $(page).each (index,value) -> $(@).find(dom_class).last().replaceWith($(@).find(dom_class).first().clone())

#计数器，用于判断是同页左右布局
count_num = do ->
  close_bag = () -> layout_count++
  close_bag

#clone节点并处理多余节点
clone_dom = (clone_page, parallel_layout_dom, count) ->
  new_page = clone_page.get(0).cloneNode()
  if not parallel_layout_dom? or count % 2 is 0
    $(clone_page).contents().each (index, value) -> $(new_page).append($(@).get(0).cloneNode())
  $(new_page).find('.container').append($(parallel_layout_dom).first().get(0).cloneNode()) if count % 2 is 0
  new_page

#clone level节点
clone_level = (level, row) ->
  row = $(row).prev()
  row = $(row).prev() while row.length and $(row).attr('level') isnt level.toString()
  row = row.clone() if $(row).attr('level') is level.toString()
  row

#clone标题
clone_title = (max_level, newpage_custom_method, index, row, rows, next_page, content_dom, parallel_layout_dom, count, page) ->
  level_array = []
  #如果是左右布局分页置换需要添加的容器
  content_dom=parallel_layout_dom if parallel_layout_dom?
  #遍历出所有可能clone的元素，level1，level2，level3...,max_level-1考虑到同级别的上一个节点返回客户没有实际意义，所以暂时屏蔽此数据
  level_array.push(clone_level(idx, row)) for idx in [0..max_level-1] if newpage_custom_method?
  #执行用户自定义方法返回需要复制到新页面的节点
  clone_array = newpage_custom_method(level_array, row)
  #添加剩余内容,区分是否是左右分页
  if parallel_layout_dom? && count % 2 isnt 0
    $(next_page).append(dom) for dom in clone_array
    $(next_page).append(rows[index..])
    return page
  else
    $(next_page).find(content_dom).append(dom) for dom in clone_array
    $(next_page).find(content_dom).append(rows[index..])
    return next_page

#分页过程
process = (page, newpage_custom_method, parallel_layout_dom) ->
  #判断是否是左右布局
  if parallel_layout_dom?
    rows = $(page).find(parallel_layout_dom).last().contents()
  else
    rows = $(page).find('.container').contents()
  #如果存在自定义方法，遍历rows获得最大级别的值
  if newpage_custom_method?
    max_level = 0
    for row, index in rows
      this_row = parseInt($(row).attr('level'))
      max_level = if this_row > max_level then this_row else max_level
  #或得页面内容总高度
  height = parseFloat($(page).find('.container').css('height'))
  #记录在同一页重复出现，需要加特殊样式的dom,提供用户自定义方法和mark_count计数器方法,用户会对需返回处理后的dom或返回当前dom（不需要处理）
  for row, index in rows
    #如果是此种分类的最后一个页面，需置空左右布局参数
    layout_count = 1 if rows.length-1 is index
    continue unless $(row).position().top + $(row).outerHeight(true) > height
    #是否有需要每页最后一项不显示的需分到下一页显示
    if parseInt($(row).prev().attr('level')) < parseInt($(row).attr('level'))
      row = $(row).prev()
      index--
    #如果有左右分页调用计数器方法
    count = count_num() if parallel_layout_dom
    #区分左右分页与上下分页的克隆page
    if parallel_layout_dom? && count % 2 isnt 0
      $(parallel_layout_dom).after(next_page = clone_dom $(parallel_layout_dom), parallel_layout_dom, count)
    else
      $(page).after(next_page = clone_dom $(page), parallel_layout_dom, count)
    #克隆需要的需要的组标题
    next_page = clone_title(max_level, newpage_custom_method, index, row, rows, next_page, '.container', parallel_layout_dom, count, page)
    return process(next_page, newpage_custom_method, parallel_layout_dom)
   
#总检分页
process $('.summary'), (level_array) ->
  level0 = $(level_array[0]).clone()
  level1 = $(level_array[1]).clone()
  return [level0, level1]
summary_special('.summary', '.hrdiv')
#物理分页
process $('.clinic'), (level_array, row) ->
  new_page_dom = []
  #复制当前节点级别前所有临近级别
  new_page_dom.push level_array[dom] for dom in [0..parseInt($(row).attr('level')-1)]
  new_page_dom
, '.groupdiv'
#实验室分页
process $('.laboratory'), (level_array, row) ->
  new_page_dom = []
  #复制当前节点级别前所有临近级别
  for dom in [0..parseInt($(row).attr('level')-1)]
    new_page_dom.push level_array[dom]
  new_page_dom
title_group_add_title('.laboratory', 'big_combo', 'H3', '2')
#项目注解特殊处理
$('.note-title').each (index, value) ->
  parent_dom = $(value).parent('.container')
  #暂时hack多出title问题
  $(parent_dom).find('.title').remove() if $(parent_dom).find('.title').next().attr('class') is 'note-title'
  if index is 0 and $(parent_dom).find('.note-title').prev().length > 0
    $(parent_dom).append("<div class='note-down'></div>")
    $(parent_dom).find('.note-title').appendTo("div.note-down")
    $(parent_dom).find('.note').appendTo("div.note-down")
  if index > 0
    $(parent_dom).find('.note-div').next().text($(parent_dom).find('.note-div').next().text()+'（续）')

#后期处理页眉、页脚、续
for page_class in ['.summary', '.clinic', '.laboratory']
  clone_header_footer page_class, part for part in ['.header', '.footer']
  group_title_continue page_class, '（续）'

#暂时hack掉骨密度（隐藏）
$("div[department='骨密度']").next().next().next().hide()
$("div[department='超声骨密度']").next().next().next().hide()
