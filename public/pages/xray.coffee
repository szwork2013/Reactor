input = ''
pattern = /^\d{8}$/
record_template =$('#record_template')
barcode = ''
#获取档案

get_record = (bcode)->

  #获取profile
  $.ajax 
    type   : 'get'
    url    : "/records/#{bcode}/profile"
    success:(profile)->
      #获取images
      $.ajax 
        type    : 'get'
        url     : "/records/#{bcode}/images"
        success : (images)->
          barcode = bcode
          images = images.filter((image)-> image.tag[0] is '放')
            .map (image)->
              tag = image.tag.substring(image.tag.lastIndexOf(':')+1)
                       
              obj ={}
              obj[tag] =
                _id :image._id
                tag :tag
              obj
          console.log images
          console.log profile
          html =  Mustache.render record_template.html(),
            profile:profile
            images :images
          $('body').html html
        error : ->
          alert('查询图片出错...')
          clear()
    error  : ->
      barcode = ''
      clear()
      alert('没有找到此档案信息...')
      
clear = ->
  $('body').empty()

#注册事件
document.addEventListener 'keydown',(event)->
  if event.keyCode is 13
    if input.length >= 8
      str = input.substring(input.length-8)
      if pattern.test str
        get_record(str)
    input =''
  else
    code =event.keyCode
    if event.keyCode>=96 &&event.keyCode<=105
      code = code-48
    input += String.fromCharCode(code)

$('select').live 'change',->
  t =$(this)
  $.ajax
    type :'put'
    url:"/records/#{barcode}/images/#{t.attr('_id')}/tag/放射科:#{t.val()}"
    success:->
      console.log('修改成功')
      t.attr 'class',t.val()
    error: ()->
      alert('修改失败...')
      t.val t.attr('class')
