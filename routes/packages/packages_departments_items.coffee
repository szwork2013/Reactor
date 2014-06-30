_  = require "underscore"
fs = require "fs"

app.get '/packages_departments_items', authorize('nurse'), (req, res) ->
  {Product, Department} = req.models
  Product.find({category: 'package'})
  .select('name configurations.name configurations.items')
  .exec (error, packages) ->
    return res.send 500, error.stack if error
    Department.find()
    .select('name items.name items._id')
    .exec (error, departments) ->
      return res.send 500, error.stack if error
      packages = packages.map (p) -> p.toObject()
      departments_hash = {}
      itemid_departmentid = {}
      items_hash = {}
      for department in departments
        departments_hash[department._id] = department.name
        for item in department.items
          items_hash[item._id] = item.name
          itemid_departmentid[item._id] = department._id
      str = ''
      for pac in packages
        str += '<br>大套餐：' + pac.name + '<br><br>'
        for config in pac.configurations
          str += '小套餐：' + config.name + '<br>'
          config.departments = []
          for itemid in config.items
            department_name = departments_hash[itemid_departmentid[itemid]]
            found_department = _.find config.departments, (d) -> d.name is department_name
            if found_department
              found_department.items.push items_hash[itemid]
            else
              config.departments.push {name: department_name, items: [items_hash[itemid]]}
          delete config.items
          config.departments = config.departments.filter (d) -> d.name
          for department in config.departments
            str += '科室：' + department.name + '<br>'
            str += '项目：' +department.items.join(',') + '<br>'
          str += '<br>'
      #fs.writeFileSync("packages_departments_items.csv", str, 'utf-8')
      res.render 'departments', {page: '套餐科室项目信息', str: str}
