fs = require 'fs'
#collections = ['products', 'batches']
collections = ['records']
parse_date = (obj, obj2, key2) ->
  obj = obj or obj2
  for key, value of obj
    if key is "$date"
      obj2[key2] = new Date value
    if key is '$oid'
      obj2[key2] = value
    if (typeof value) is 'object'
      parse_date value, obj, key
    else
      obj[key] = value
  obj

for name in collections
  datas = eval fs.readFileSync("./export_json/#{name}.json") + ''
  for data in datas
    #data = parse_date data
    fs.writeFileSync "./samples_data/#{name}/#{(if not data.category or name isnt 'products' then '' else if data.category is 'combo' then 100 else 200) + (data.order or '')}_#{(data.name or data.barcode or data.company or data._id["$oid"] or data._id)}.js", JSON.stringify(data, null, 2)
