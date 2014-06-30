# html、css定义规范
# 封面：.Cover
# 序：.Foreword
# 目录：.Toc
# 内容：.Content
# 标题：h1、h2...
# 标题类名：.title_h1、.title_h2...
# 每种模板div中加.log-page,需要复制业头多的模板多加一个.on样式

#打印页码
setPageNum = (pages) ->
  $(pages).each (index)->
    $(this).append("<div class='page_number' >#{index+1}</div>")

#打印附录
set_appendix = (pages, context) ->
  $(pages).each ()->
    $(this).append("<div class='fujian'>#{context}</div>")

#页面备注
set_mark = (pages) ->
  mark1 = """
  <div class='zhushi'>
  <span>⊘</span>不适用项；<span>●</span>男宾已选项；<span>●</span>女宾已选项；<span>●</span>男女通用已选项；
  <span>○</span>男宾未选项；<span>○</span>女宾未选项；<span>○</span>男女通用未选项
  </div>"""
  mark2 = "<div class='zhushi_p'><span>＊</span>现场自费价：非团体结算的自费宾客，可享用此优惠价格现场结算。</div>"
  
  $(pages).each (index)->
    if $(pages).length is 1
      $(this).append mark1+mark2
    else
      if index is $(pages).length-1
        $(this).append mark2
      else
        $(this).append mark1

#生成目录
#目前只支持一层目录，如果遇到多层的时候再改进程序？
#如果是多层拿each里的每一个h1标题去判断是否有h2（h2会是个类似title_h2的然后我用hasClass方法进行判断）
#如果有3级标题以此类推（程序最多判断到3级标题）
createCatalogue = ()->
  $('.title_h1').each () ->
    $('.catalogue').append("<dl><dt>#{$(this).text()}</dt><dd>#{$(this).parent().parent().find('.page_number').text()}</dd><span></sapn></dl>")

process = (page, clone_first_row) ->
  rows = $('.row', page)
  height = parseFloat($(page).css('height'))
  for row, index in rows
    if $(row).hasClass('ullist') && index != 0
      $(page).after(next_page = page.cloneNode())
      $(next_page).append(rows[index..])
      return process next_page, clone_first_row
    continue unless $(row).position().top + $(row).outerHeight(true) > height
    console.log $(row).next()
    #debugger
    # 分组不在页面最下方
    if $(row).prev().hasClass('group')
      row = $(row).prev()[0]
      index--
    $(page).after(next_page = page.cloneNode())
    $(next_page).append($(rows[0]).clone()) if clone_first_row # 套餐列表

    # 续
    if not $(row).hasClass('group') && $(row).next().hasClass('row') && not $(row).hasClass('pricediv') # OKAY
      row = $(row).prev()
      row = $(row).prev() while row.length and not row.hasClass('group') # CoffeeScript里面没有do... while
      if row.hasClass('group')
        row = row.clone()
        cont = $('[cont]', row)
        cont.text cont.attr('cont') + '（续）'
        $(next_page).append($(row)) # 分组
    $(next_page).append(rows[index..])
    return process next_page, clone_first_row

#分页
$('.log-page').each () ->
  process $(@)[0], $(@).hasClass('on')
#标记附件
set_appendix $('.appendix1'), '附件一'
set_appendix $('.appendix2'), '附件二'
set_appendix $('.appendix3'), '附件三'
#添加备注
set_mark $('.mark')
#打印页码
setPageNum $('.content')
#创建目录
createCatalogue()
