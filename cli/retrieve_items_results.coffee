_       = require "underscore"
request = require "superagent"
async   = require "async"
models  = require "../models"

models 'test.healskare.com', (error, models) ->
  {Record} = models
  Record.find({appeared: {'$ne': []}, status: {'$in': ['已完成', '已打印']}})
  .select('barcode')
  .sort('barcode')
  .exec (error, records) ->
    return console.log error if error
    barcodes = _.pluck records, 'barcode'
    console.log barcodes.length, 'count'
    datas   = []
    tasks = barcodes.map (barcode) ->
      (callback) ->
        Record.findOne({'barcode': barcode})
        .select('profile barcode departments')
        .exec (error, record) ->
          return console.log error if error
          return callback() if not record.profile.name.match(/(测试|盛保善)/) and not record.profile.division?.match(/自费/)
          for department in record.departments
            if department.name is '生化检验'
              found_dgc  = _.find department.items, (item) -> item.name is '胆固醇'
              found_gysz = _.find department.items, (item) -> item.name is '甘油三酯'
              console.log record.profile.age, found_dgc, found_gysz, '11111111111'
              if found_dgc and found_gysz
                if record.profile.age >= 18 and record.profile.age <= 75 \
                and found_gysz.value >= 0 and found_gysz.value <= 18.6
                  datas.push
                    tel: record.profile.tel
                    check_date: record.profile.check_date
                    age: record.profile.age
                    name: record.profile.name
                    sex: record.profile.sex
                    dgc: found_dgc.value
                    gysz: found_gysz.value
          callback()
    async.parallelLimit tasks, 1000, (error) ->
      console.log if error then error else '成功'
      datas = datas.filter (data) -> data.tel
      str = '电话, 体检日期, 年龄, 姓名, 性别, 胆固醇, 甘油三酯\n'
      datas = datas.sort (a, b) -> if a.dgc > b.dgc then -1 else 1
      for data in datas
        str +=  (data.tel or '') + ',' + data.check_date + ',' + data.age + ',' + data.name + ',' + data.sex + ',' + data.dgc + ',' + data.gysz + '\n'
      fs.writeFileSync 'datas1.csv', str, 'utf-8'
      process.exit()
