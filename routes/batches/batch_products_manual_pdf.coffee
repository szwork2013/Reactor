{spawn, exec} = require 'child_process'
moment        = require 'moment'

app.get '/batches/:batch_id/configurations_brochure.pdf', (req, res) ->
  {batch_id} = req.params
  {Batch, Record}    = req.models
  url = "http://#{req.host}:5124/batches/" + batch_id + '/configurations_brochure'
  path = __dirname + '/../../public/pdfs/batch_configurations/' + batch_id + '.pdf'
  options =[
    url
    path
  ]
  grep = exec 'osascript html2pdf2 ' + options.join(' '), {cwd: __dirname + '/../../utils', timeout: 50000}, (err, stdout, stderr) =>
    if err
      grep.kill 'SIGKILL'
      console.log err, stderr, stdout
      return res.send err if err
    Batch.findOne({_id: batch_id})
    .select('company')
    .exec (error, batch) ->
      return res.send error.stack if error
      res.set "Content-Disposition", "inline; filename*=utf-8''#{encodeURIComponent(moment(batch.registration.date_string).format('YYYY年') + '_' + batch.company)}.pdf"
      res.sendfile('./public/pdfs/batch_configurations/' + batch_id + '.pdf')
