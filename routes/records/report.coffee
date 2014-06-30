# 渲染PDF
#
# ## 获取的个人档案信息
#   + **资源地址**
#   + `/reports/:id`
#     * `id`：档案编号或者25条码编号
#   + **例**
#     * /reports/00000004
#
#   + 返回数据
#   {
#     "profile": {
#       "name": "王六一",
#       "sex": "male",
#       "source": "物理所补检",
#       "age": "24"
#      },
#      "appeared": "2013年01月25日",
#      "clinic_items": [
#        {
#         "item": "甲状腺彩超",
#         "department": "颈部彩超",
#         "value": "<span>甲状腺结节<span>10cm</span>至<span>20cm</span></span>",
#         "normal": false
#        }
#      ],
#      "laboratory_items": [],
#      "giveup_clinic_departments": [],
#      giveup_lab_departments: [],
#      "laboratory_doctors": [],
#      "clinic_doctors": [
#        {
#         "name": "王雅欣",
#         "departments": [
#           "颈部彩超"
#         ]
#        }
#      ],
#      suggestions: [{content:'', conditions: ''}]
#   }
#
# ## 数据服务（应用于渲染PDF）
#   + 根据条件查询数据
#   + 查询成功返回`record`，失败发送400错误信息，未找到发送404
{exec}         = require 'child_process'
fs             = require 'fs'
# qrcode         = require 'qrcode'
moment         = require "moment"
_              = require "underscore"
marked         = require 'marked'
{date2chinese} = require '../../utils/date2chinese.js'

app.get /^\/reports\/(\w+)(?:\.([pdf]+))?$/, authorize('admin', 'doctor', 'nurse'), (req, res) ->
  barcode = req.params[0]
  pdf     = req.params[1]
  {Record} = req.models
  if pdf and pdf is 'pdf'
    file_path = './public/pdfs/reports/' + barcode + '.pdf'
    Record.findOne({barcode: barcode})
    .select('barcode profile.source profile.division profile.name')
    .exec (error, record) ->
      return res.send 500, error.stack if error
      fs.exists file_path, (exists) ->
        filename = record.profile.source + '_' + (record.profile.division or '') + '_' + record.profile.name + '_' + barcode
        if exists
          res.set "Content-Disposition", "inline; filename*=utf-8''#{encodeURIComponent(filename)}.pdf"
          res.sendfile(file_path)
        else
          Record.summarization_and_create_pdf barcode, (error) ->
            return res.send 500, error.stack if error
            res.set "Content-Disposition", "inline; filename*=utf-8''#{encodeURIComponent(filename)}.pdf"
            res.sendfile(file_path)
  else
    Record.barcode barcode, {paid_all: on}, (error, record) ->
      return res.send 500, error.stack if error
      return res.send 404 unless record
      record.get_record_combos (error, {laboratory_combos, notes}) ->
        return res.send 500, error.stack if error
        if not record.hbv_agreement_signed
          found_department = _.find record.departments, (d) -> d.name is '免疫检验'
          if found_department
            found_department.items = found_department.items.filter (item) -> not item.name.match(/乙肝/)
            if not found_department.items.length
              record.departments = record.departments.filter((d) -> d.name isnt '免疫检验')
            record.sync_status()
        departments = JSON.parse JSON.stringify record.departments
        # 调整科室数据
        record.adjust_departments_data()
        # 临床放弃科室
        giveup_clinic_departments = record.get_giveup_clinic_departments()
        # 实验室放弃科室
        giveup_lab_departments = departments
        .filter((d) -> d.category is 'laboratory' and d.status is '放弃')
        .map (d) -> d.name
        {doctors, render_items} = record.get_render_data()
        
        # 用来渲染的临床项目
        clinic_items       = render_items.filter (item) -> item.category is 'clinic'
        # 用来渲染的实验室项目
        laboratory_items   = render_items.filter (item) -> item.category is 'laboratory'
        # 用来渲染的临床医生
        clinic_doctors     = doctors.filter (doctor) -> doctor.category is 'clinic'
        # 用来渲染的实验室医生
        laboratory_doctors = doctors.filter (doctor) -> doctor.category is 'laboratory'
        #record.orders = record.orders.sort((a, b) -> if [2,0,1].indexOf(a.paid) > [2,0,1].indexOf(b.paid) then 1 else -1)
        record.orders = _.sortBy record.orders, (value)-> return value if value.category is 'package'
        order_names = record.orders.filter((order) -> order.paid).map (order) ->
          order.name.replace(/([\（\）\[ \] \{ \}]|[\^\$\.\*\+\-\?\=\!\|\、\:\：\w]+)/g, ($0) -> (if $0 in ['（', '）'] then "<span class='kuohao'>" else "<span>")+ $0 + "</span>")
        departments  = departments.filter (d) -> d.name not in Record.ignore_departments()
        laboratory_items = record.varianted_laboratory_combos laboratory_items, laboratory_combos
        notes = notes.filter((note) -> laboratory_items.some((item) -> item.small_combo is note.name))
        .map((note, index) -> '<b>' + (index + 1) + '</b>' + marked(note.note))

        report_data =
          barcode:   record.barcode
          status:    record.status
          profile:   record.profile
          order_names:  order_names
          combo_notes:  notes
          notes:     record.profile.notes.filter((note) -> not note.match(/电子报告/)).join()
          employee_id: _.find(record.profile.notes, (note) -> note.match /员工编号/)
          clinic_items: clinic_items
          giveup_clinic_departments: giveup_clinic_departments
          unfinished_clinic_departments: departments.filter((d) -> d.category is 'clinic' and d.status is '未完成').map((d) -> d.name)
          unfinished_laboratory_departments: departments.filter((d) -> d.category is 'laboratory' and d.status in ['未完成','待检验','已上机未完成','待审核']).map((d) -> d.name)
          clinic_doctors: clinic_doctors
          laboratory_items: laboratory_items
          giveup_lab_departments: giveup_lab_departments
          laboratory_doctors: laboratory_doctors
          suggestions: record.get_render_suggestions()
          outer: record.profile.notes.some((note) -> note.match /外检/)
          x_ray_report: []
          #clinic_all_giveup: departments.filter((d) -> d.category is 'clinic').every((d) -> d.status is '放弃')
          #lab_all_giveup: departments.filter((d) -> d.category is 'laboratory').every((d) -> d.status is '放弃')
        
        if appeared = record.appeared[0]
          report_data['appeared']  = date2chinese(appeared)
          report_data['next_time'] = moment(appeared).add('years', 1).format('YYYY年MM月')
        report_data["biochemistry_auditor"] = record.biochemistry?.audit?.user_name if record.biochemistry?.audit?.user_id

        # 整理放射科项目、图片、描述和诊断
        found_fsk = _.find departments, (d) -> d.name is '放射科'
        if found_fsk
          for item in found_fsk.items
            fsk_images = record.images.filter((image) -> image.tag?.match(item.name))
            if fsk_images.length
              report_data.x_ray_report.push
                name: item.name
                images: fsk_images
                description: item.description
                diagnose: item.normal or _.pluck(item?.conditions, 'detail').join('。')
        
        # 整理tct报告数据
        report_data.tct_report = record.images.filter((image) -> image.tag is '宫颈超薄细胞学检测')?[0]
        found_tct_sample = _.find record.samplings, (s) -> s.name is 'TCT标本'
        found_fuke = _.find record.departments, (d) -> d.name is '妇科'
        found_tct  = _.find record.departments, (d) -> d.name is '宫颈超薄细胞学检查'
        found_item = _.find found_tct?.items, (item) -> item.abbr is 'TCT'
        value      = found_item?.value
        if report_data.tct_report
          if value
            value = JSON.parse value
            tct_sample   = value['样本']
            tct_diagnose = value['诊断']
            report_data.tct_report.satisfaction =     tct_sample[0].match(/不满意|满意/)?[0] or ''
            report_data.tct_report.cellvolume   =     if tct_sample[1].match(/大于百分之四十/) then '>40%' else '<40%'
            report_data.tct_report.neckcell     =     tct_sample[2].match(/有|无/)?[0] or ''
            report_data.tct_report.metaplastic_cell = tct_sample[3].match(/有|无/)?[0] or ''
            report_data.tct_report.squamous_cell =    tct_sample[4].match(/有|无/)?[0] or ''
            for result_key, names of tct_results
              report_data.tct_report[result_key] = if names.some((name) -> name in tct_diagnose) then 'ifon_c' else 'ifon_b'
            report_data.tct_report['result1'] = 'ifon_a' if report_data.tct_report['result1'] is 'ifon_c'
          sample_date = moment(found_tct_sample?.sampled?.date_string)
          report_data.tct_report.sample_date   = sample_date.format('YYYY年MM月') + sample_date.dates() + '日'
          report_data.tct_report.sample_doctor = found_fuke?.checking?.finished?.user_name
          report_data.tct_report.diagnose_doctor = '李晓明'
          report_data.tct_report.conditions = if found_item?.normal then [found_item?.normal] else _.pluck(found_item?.conditions, 'name')
        
        report_data.ultrasound_images = record.images.filter (image) ->
          image.tag?.match /超声影像/
        report_data.ecg_images = record.images.filter (image) ->
          image.tag?.match /心电图/
      
        #res.send report_data
        res.render 'report', report_data

tct_results =
  "result1":  ["未见上皮内病变和癌细胞"]
  "result2":  ["鳞状上皮内细胞低度病变"]
  "result3":  ["鳞状上皮内细胞高度病变"]
  "result4":  ["阴道滴虫"]
  "result5":  ["真菌（形态符合念珠菌属）"]
  "result6":  ["菌群变化（提示细菌性阴道病）"]
  "result7":  ["HPV病毒感染"]
  "result8":  ["细菌（形态符合放线菌属）"]
  "result9":  ["细胞变化（符合单纯疱疹病毒感染）"]
  "result10": ["反应性细胞改变（轻度炎症）","反应性细胞改变（中度炎症）","反应性细胞改变（重度炎症）"]
  "result11": ["反应性细胞改变（萎缩）"]
  "result12": ["反应性细胞改变（宫内节育器）"]
  "result13": ["反应性细胞改变（放疗）"]
  "result14": ["非典型鳞状细胞（不能明确意义）"]
  "result15": ["非典型鳞状细胞（倾向于上皮内高度病变）"]
  "result16": ["癌细胞及恶性细胞（鳞状细胞癌）"]
  "result17": ["癌细胞及恶性细胞（腺癌）"]
  "result18": ["癌细胞及恶性细胞（其他恶性肿瘤）"]
