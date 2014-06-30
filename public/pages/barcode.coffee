bcode = ''

patterns = []

document.onkeydown = (evt) ->
  if evt.keyCode is 13
    for {pattern, callbacks} in patterns
      match = bcode.match pattern
      if match
        # 在文本框或文本域中扫码后，需要删除扫码字符，
        # 并保持光标位置。
        if document.activeElement?.tagName in ['INPUT', 'TEXTAREA']
          evt.preventDefault()
          selectionEnd = document.activeElement.selectionEnd - match[0].length
          val = document.activeElement.value.replace match[0].toLowerCase(), ''
          document.activeElement.value = val
          document.activeElement.selectionEnd = selectionEnd
        _.each callbacks, (callback) ->
          callback match[0]
        bcode = ''
        return
    bcode = ''
  else
    bcode += String.fromCharCode evt.keyCode if evt.keyCode isnt 16
   

window.barcode =
  regist: (pattern, callback) ->
    pattern_string = pattern.toString()
    found_pattern = _.find patterns, (p) ->
      p.pattern.toString() is pattern_string
    if found_pattern
      found_pattern.callbacks.push callback
    else
      patterns.push
        pattern: pattern
        callbacks: [callback]
  clear: ->
    patterns = []
