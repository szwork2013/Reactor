window.download = (path) ->
  iframe = document.createElement 'iframe'
  $(iframe).css 'display', 'none'
  iframe.src = path
  document.body.appendChild iframe
