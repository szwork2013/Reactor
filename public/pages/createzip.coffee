$('#datepicker').datepicker
  format: 'yyyy-mm-dd'
.on 'changeDate',  ->
  download "/records/createzip/#{@value}"
 
