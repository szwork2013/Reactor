models       = require "./models"
subdomain    = 'hswk.healskare.com'
fs =require 'fs'
_ = require 'underscore'
exports.import =(datas,asycall) ->
  console.log JSON.stringify(datas)
  models subdomain, (error, models) ->
    err_msg = {}
    asycall '读取数据失败' if error
    {Record} = models
    index = 0
    raw_rows =[]
    keys = _.keys datas
    #TODO 
    _import = ->

      if index is keys.length
        if _.keys(err_msg).length then return asycall('',err_msg) else return asycall()
      else
        raw_rows =  datas[keys[index]].reduce (c,p) ->
          c += p.entries.length
        ,0

        Record.import_multi_records_entries datas[keys[index]],keys[index],'李晓明',(err,raw_items,valid_items,total_groups)->
          if err
           err_msg[keys[index]] = err
          valid_rows = valid_items
          console.log "共有#{raw_rows}个项目,已导人#{valid_items}个项目，未导入#{raw_rows-valid_items}个项目"
          index++
          _import()

    _import()
