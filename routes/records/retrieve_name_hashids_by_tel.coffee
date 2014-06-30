app.get '/records/:tel/name_hashids', (req, res) ->
  {Record} = req.models
  Record.get_name_hashids_by_tel req.params.tel, (error, results) ->
    return res.send 500, error.stack if error
    res.send results
