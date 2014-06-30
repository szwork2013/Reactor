$('#datepicker').datepicker
  format: 'yyyy-mm-dd'
.on 'changeDate',  ->
  download "/statistics/immunoassay/#{@value}"
 
