
module.exports = (record_schema) ->
  # 生日
  record_schema.statics.getBirthday = (id) ->
    if id.length is 18
      return id.substr(6,4) + '-' + id.substr(10,2) + '-' + id.substr(12,2)
    else if id.length is 15
      return "19" + id.substr(6,2) + "-" + id.substr(8,2) + "-" + id.substr(10,2)
    else if id.length is 10
      return id
