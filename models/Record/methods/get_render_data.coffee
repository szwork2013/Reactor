_ = require 'underscore'

module.exports = (record_schema) ->
        
  record_schema.methods.get_render_data = () ->

    # 要渲染的项目
    render_items = []
    # 医生
    doctors = []
    {sex, age}  = @profile
    console.log @barcode, 'barcode'
    # 特殊项目单位
    item_unit =
      '身高': 'cm'
      '体重': 'kg'
      '血压': 'mmHg'
      '心率': '次/分'
    # 排除已放弃的科室
    departments = @departments.filter (d) ->
      d.status isnt '放弃'
    
    for department in departments
      if name  = department?.checking?.finished?.user_name
        names  = [name]
        if department.name is '放射科'
          names  = _.uniq(department.items.map((item) -> item.checking?.finished?.user_name))
        doctor = _.find doctors, (doctor) -> doctor.names.join() is names.join()
        department_name = department.name.replace(/[\w]+/g, ($0) -> '<span>' + $0 + '</span>')
        doctor.departments.push department_name if doctor
        doctors.push names: names, departments: [department_name], category: department.category unless doctor
      is_first_item = on
      #department.name = '彩色超声' if department.name.match(/彩超/)
      #department.name = '一般情况' if department.name in ['身高体重', '血压', '腰臀比', '体脂率']
      #found_department = _.find render_departments, (d) -> d.name is department.name
      #render_department = found_department or {name: department.name, category: department.category, items: []}
      for item in department.items
        continue if not @hbv_agreement_signed and item.name.match(/乙肝/)
        render_item = _id: item._id, item: item.name, category: department.category
        render_item['department'] = department.name if is_first_item # and item.name isnt '视力'
        render_item['department'] = '彩色超声' if department.name.match(/彩超/)
        render_item['department'] = '一般情况' if department.name in ['身高体重', '血压', '腰臀比', '体脂率']
        is_first_item = off unless item.name is '视力'
        conditions = item.conditions.map((c) -> c.detail or c.name).map (name) ->
          name = name.replace /[\w\.\×\-\s]+/g, ($0) -> "<span class = 'more'>"+ $0 + "</span>"
          '<span>' + name + '</span>'
        value = ''
        item.value = item.value + ' ' + item_unit[item.name] if item_unit[item.name]
        value = (item.value or item.normal) unless conditions.length and item.name isnt '其他'
        value = (item.value or conditions.join('')) if conditions.length
        if item.name.match('骨密度')
          value = if conditions.length then conditions.join('') else item.normal
        if item.name is '宫颈超薄细胞学检查' and item.value
          if item.value.match(/\{/)
            value = JSON.parse(item.value)
          value = if value?['诊断'] then value?['诊断'].join('、') else value
        if item.status is '放弃'
          value = item.status
          render_item['normal'] = on
        continue if item.name is '其他' and value is '无'
        render_item['value'] = value
        render_item['normal'] = if item.normal or item.name.match /乙肝病毒/ then on else off
        if item.conditions.every((c) -> c.name in ['窦性心律', '窦性心律不齐', '正常心电图', '大致正常心电图'])
          render_item['normal'] = on
        if item.conditions.length is 1 and value.match(/绝经后子宫/)
          render_item['normal'] = on
        if department.category is 'laboratory'
          if item.status is '放弃' or isNaN(item.value)
            render_item['range'] = '—'
          else
            render_item['range'] = item.lt + ' - ' + item.ut if item.ut? and item.lt?
            render_item['range'] = '≧' + item.lt if not item.ut? and item.lt?
            render_item['range'] = '≤ ' + item.ut if not item.lt? and item.ut?
            # 当有上限没下限或者有下限没上限，且值为0.00，则取值范围是0
            if (not item.lt? and item.ut? and not parseFloat(item.ut)) \
            or (not item.ut? and item.lt? and not parseFloat(item.lt))
              render_item['range'] = '0'
          if not isNaN(item.value)
            if parseFloat(item.value) > parseFloat(item.ut)
              render_item['arrow'] = 'up'
            if parseFloat(item.value) < parseFloat(item.lt)
              render_item['arrow'] = 'down'
          render_item['unit']  = (item.unit or '—')
          render_items.push render_item
        else
          if render_items.some((c) -> c.department is '彩色超声') and render_item.department is '彩色超声'
            delete render_item.department
          if render_items.some((c) -> c.department is '一般情况') and render_item.department is '一般情况'
            delete render_item.department
          render_items.push render_item if item.name isnt '视力'
          if item.name.match('骨密度') and item.value
            value = JSON.parse item.value
            normal = if item.normal then on else off
            render_items.push category: department.category, item: '骨密度指数', value: value.OI, normal: normal
            render_items.push category: department.category, item: ('是' + age + '岁' + sex + '性骨密度的'), value: value.Z + '%', normal: on
            if age > 20
              render_items.push category: department.category, item: ('是20岁'+ sex + '性骨密度的'), value: value.T + '%', normal: on
          if item.name is '视力' and item.value
            values = item.value.split('|')
            normal = if item.normal then on else off
            if values[0]?.trim().match(/\d/) or values[1]?.trim().match(/\d/)
              sights = values[0].split(',')
              raw = sights?[0] and sights?[1] and sights?[0] isnt 'placeholder' and sights?[1] isnt 'placeholder'
              if sights?[0] and sights?[1] and sights?[0] isnt 'placeholder' and sights?[1] isnt 'placeholder'
                render_items.push category: department.category, item: '裸眼视力', value: '左眼' + sights[0] + '，右眼' + sights[1], normal: normal, department: '眼科'
                is_first_item = off
              sights = values[1].split(',')
              if sights?[0] and sights?[1] and sights?[0] isnt 'placeholder' and sights?[1] isnt 'placeholder'
                render_items.push category: department.category, item: '矫正视力', value: '左眼' + sights[0] + '，右眼' + sights[1], normal: normal, department: if raw then undefined else '眼科'
                is_first_item = off
    doctors: doctors, render_items: render_items
