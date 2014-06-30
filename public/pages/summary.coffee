template = $('#summary_template').html()

render_summary = () ->
  item = $('#sel_item').val()
  date = $('#datepicker').val()
  $.ajax
    url    : '/statistics/sampling_complete_situation/' + item + '/' + date
    type   : 'GET'
    error  : (error) -> console.log error
    success: (data) ->
      $('#content').html Mustache.render(template, data)

$('#sel_item').change ->
  value = $(@).val()
  $('#title').html value
  render_summary() if $('#datepicker').val()

  #render_summary '生化检验'
$('#datepicker').datepicker
  format: 'yyyy-mm-dd'
.on 'changeDate',  ->
  $('.dropdown-menu').hide()
  $(@).blur()
  date = $(@).val()
  render_summary()

today = moment()
$('#datepicker').val today.format('YYYY-MM-DD')
render_summary()
