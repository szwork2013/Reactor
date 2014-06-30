_      = require "underscore"


module.exports = (record_schema) ->
 
  # TODO: 更改签名，默认为仅检索已付费或记帐项目，大多数情况允许不传入配置参数。
  # options.paid_all 为 off 时，表示查询所有订单中科室的状态
  # options.paid_all 为 on 时，表示只查询已付费或事后付费的科室状态
  record_schema.methods.sync_departments = (options, cb) ->
    # TODO: 参考同行常见的可选参数实现模式
    # http://mongoosejs.com/docs/api.html#model_Model.find
    # 这样的优势在于第一步定位参数；第二步处理参数。我们下面的写法把paid_all的解析分到了
    # 多个地方:( 在参数处理比较复杂的时候，对代码阅读者的IQ挑战很大。但是第一步先定位参数，
    # 第二步就按步就班了。
    #
    # if 'function' is typeof options
    #   callback = options
    #   options = {}
    # 
    # 可以这样写，但是我们要清楚，这样的调用模式 sync_departments null, -> blablah
    # 会抛出异常。如果改进，给options默认值：(options = {}, callback) ->
    if 'function' is typeof options
      cb = options
      options = {}

    {paid_all} = options
    products = []
    products = @products()

    # 所有产品编号`all_product_ids`
    # 未付费产品编号`unpaid_product_ids`

    all_product_ids = []
    unpaid_product_ids = []
    
    for product in products
      all_product_ids.push product._id
      unpaid_product_ids.push product._id.toString() unless product.paid
    @model('Product').get_combos_by_orderids all_product_ids, (error, orderid_combos) =>
      return cb error if error
      order_status = products.reduce (memo, order) ->
        memo[order._id] = order.paid
        memo
      , {}
      # 根据产品项目编号`all_product_ids`，得到`item_ids`数组。
      # 通过Aggregation Framework降低IO开销。
      #
      #   1. $match "configurations._id": {$in: all_product_ids}
      #   2. $unwind "$configurations"
      #   3. $match "configurations._id": {$in: all_product_ids}
      #   4. $unwind:"$configurations.items"
      #   3. $project: {item_id: "configurations.items",product_id:"$configurations._id"}
      commands = [
        ($match  : 'configurations._id': '$in': all_product_ids)
        ($unwind : '$configurations')
        ($match  : 'configurations._id': '$in': all_product_ids)
        ($unwind : '$configurations.items')
      ]
      commands.push
        $project:
          item_id: "$configurations.items"
          product_id: "$configurations._id"

      @model('Product').aggregate commands, (error, items) =>
        return cb error if error
        
        item_ids     = []
        unpaid_items = []
        paid_items   = []
        unpaid_product_ids = unpaid_product_ids.map (id) -> id.toString()
        
        for item in items
          item_ids.push item.item_id
          if item.product_id.toString() in unpaid_product_ids
            unpaid_items.push item.item_id
          else
            paid_items.push item.item_id
        
        # 条件 ：已知项目item_ids
        # 获取全部科室／项目数据，取`_id,name,category,sampling_required,items._id,items.name`键，
        # 得到`departments`数组。
        # 通过Aggregation Framework降低IO开销。
        #
        #   1. $match: "items._id": {$in: item_ids} 
        #   2. $unwind:"$items"
        #   3. $match: "items._id":{$in: item_ids} 
        #   4. $group:
        #        _id: $_id
        #        name: 
        #          $first : "$name" 
        #        category: 
        #          $first : "$category" 
        #        items:
        #          $push :
        #            '_id': '$items._id'
        #            'name':'$items.name'
        commands  = []
        item_ids = if paid_all then paid_items else item_ids
        # TODO: 将`if paid_all then paid_items else item_ids`的逻辑在一处叙述。
        commands.push $match :
          'items._id' :
            '$in': item_ids
        commands.push $unwind:
          '$items'
        commands.push $match:
          'items._id':
            '$in': item_ids
        commands.push $group:
          _id: '$_id'
          name:
            $first : "$name"
          order:
            $first:  "$order"
          category:
            $first : "$category"
          items:
            $push :
              _id:  "$items._id"
              name: "$items.name"
              abbr: "$items.abbr"
              byname: "$items.byname"
              # TODO: 档案中不持久化计算项目的表达式，可以么? 
              # TODO: 导入思路沟通之后再评估。
              expression: "$items.expression"
              sex:  "$items.sex"
              ut:   "$items.ut"
              lt:   "$items.lt"
        # TODO: 在这里排序，是否亦不能保证档案中科室顺序? 所以可否不再做这个工作。
        commands.push $sort:
          category : 1
          order: 1
        @model('Department').aggregate commands, (error, departments) =>
          return cb error if error
          unpaid_items =  unpaid_items.map (item) -> item.toString()
          # 如需要将项目从`departments`中转移到档案中，并通过API交换，需要保证包含项目状态。
          for department in departments
            department.items = department.items.filter (item) =>
              not item.sex or item.sex is @profile.sex
            for item in department.items
              item.status = if item._id.toString() in unpaid_items then '未付费' else '未完成'
            department.status = if department.items.some((item) -> item.status is '未完成') then '未完成' else '未付费'
          # 删除档案科室有的项目但科室集合中没有的未付费项目或未完成项目
          for department in @departments
            # 过滤掉订单中没有的未完成的科室纪录
            found_department = _.find departments, (d) -> d._id.equals department._id
            if found_department
              ids = _.pluck(found_department.items, '_id').map (id) -> id.toString()
              department.items = department.items.filter((i) -> i._id.toString() in ids or i.status is '已完成')
            else
              department.items = department.items.filter (item) -> item.status is '已完成'

          # 将订单中新的科室信息添加到档案科室信息中
          # 将订单中新的项目信息添加到档案中已存在的科室中
          for department in departments
            if found_department = @departments.id department._id
              for item in department.items
                found_item = found_department.items.id item._id
                if not found_item
                  found_department.items.addToSet item
                else if found_item.status is '未付费'
                  found_item.status = item.status
              found_department.status = department.status if found_department.status is '未付费'
            else
              @departments.addToSet department

          samplings_departments   = {}
          special_unpaid_sampling = {}
          gene_status = ''
          for order_id, combos of orderid_combos
            # 对于某些组合需要出条码的采样信息
            if (combos.some (name) -> name?.match /基因检测（血液标本）/)
              samplings_departments['紫色采血管（1）'] = ['基因检测']
              gene_status = if (@orders.id order_id).paid then '未采样' else '未付费'
            if (combos.some (name) -> name in ['乙肝表面抗原', '乙肝五项'])
              samplings_departments['HBV知情书'] = []
            if (combos.some (name) -> name?.match /基因检测（口腔黏膜标本）/)
              samplings_departments['基因检测口腔标本盒'] = []
            if (combos.some (name) -> name?.match /基因检测（唾液标本）/)
              samplings_departments['基因检测唾液标本盒'] = []
            if (combos.some (name) -> name?.match /早餐/)
              samplings_departments['早餐'] = []
              special_unpaid_sampling['早餐'] = '未付费' unless order_status[order_id]
          
          for department in @departments
            for sampling in department.required_samplings
              samplings_departments[sampling] or = []
              samplings_departments[sampling].push department.name
   
          new_samplings = for name, sample_departments of samplings_departments
            vessel = vessels[name]
            departs = @departments.filter((d) -> d.name in sample_departments)
            people =
              _id: @barcode + vessel.code
              name: name
              tag: vessel.tag or vessel.tags?[sample_departments.sort((a,b) -> if a>b then 1 else -1).join('')]
              biochemistry: biochemistry = (sample_departments.some (name) -> name is '生化检验')
              apps: if biochemistry then ['生化'] else []
              status: if (departs.length and departs.every((d) -> d.status is '未付费') or special_unpaid_sampling[name]) then '未付费' else '未采样'
            people.status = gene_status if sample_departments[0] is '基因检测'
            people

          # 待标记为无效的样本
          for sampling in @samplings when sampling.status in '已采样' \
          and not new_samplings.some((new_sampling) -> new_sampling._id is sampling._id)
            sampling.status = '已删除'
          # 待删除的样本
          @samplings.remove @samplings.filter((sampling) ->
            sampling.status in ['未采样', '未付费'] and not new_samplings.some((new_sampling) -> new_sampling._id is sampling._id))...
          
          # 待更新的样本
          for sampling in @samplings when new_sampling = _.find(new_samplings, (new_sampling) -> new_sampling._id is sampling._id)
            delete new_sampling.status if sampling.status in ['已删除', '已采样']
            _.extend sampling, new_sampling
            sampling.status = '已采样' if sampling.status in ['已删除']
          
          # 待添加的样本
          for sampling in new_samplings when not @samplings.id sampling._id
            @samplings.push sampling

          if paid_all
            for department in @departments
              department.items = department.items.filter (item) -> item.status isnt '未付费'
         
          # TODO: 如果你可以帮助mongoose一下，不使用赋值语句，而使用`pull`，
          # mongoose会感激的，因为
          # 过滤掉没有项目的科室
          @departments = @departments.filter (d) -> d.items.length
          cb()

vessels =
  '黄色采血管（1）': code: '01', tag: '生化'
  '黄色采血管（2）': code: '02', tag: '免疫'
  '紫色采血管（1）':
    code: '03'
    tags: [
      departments: ['生化检验', '血常规', '血型','基因检测']
      tag: '血常规、血型、糖、基因检测'
     ,
      departments: ['生化检验', '血常规', '基因检测']
      tag: '血常规、糖、基因检测'
     ,
      departments: ['血常规', '血型', '基因检测']
      tag: '血常规、血型、基因检测'
     ,
      departments: ['生化检验', '血型','基因检测']
      tag: '血型、糖、基因检测'
     ,
      departments: ['生化检验', '血常规', '血型']
      tag: '血常规、血型、糖'
     ,
      departments: ['生化检验', '基因检测']
      tag: '糖、基因检测'
     ,
      departments: ['血常规', '基因检测']
      tag: '血常规、基因检测'
     ,
      departments: ['血型','基因检测']
      tag: '血型、基因检测'
     ,
      departments: ['生化检验', '血型']
      tag: '血型、糖'
     ,
      departments: ['血常规', '血型']
      tag: '血常规、血型'
     ,
      departments: ['生化检验', '血常规']
      tag: '血常规、糖'
     ,
      departments: ['生化检验']
      tag: '糖'
     ,
      departments: ['血型']
      tag: '血型'
     ,
      departments: ['血常规']
      tag: '血常规'
     ,
      departments: ['基因检测']
      tag: '基因检测'
    ]
  '绿色采血管（1）':  code: '04', tag: '血流变'
  '绿色采血管（2）':  code: '05', tag: '全血微量元素'
  '黑色采血管':       code: '06', tag: '血沉'
  'TCT标本':  code: '08'
  '宫颈刮片': code: '09'
  '白带常规': code: '10'
  '心电图':   code: '11'
  '尿杯':     code: '12', tag: '尿常规'
  '便盒':     code: '13', tag: '便常规'
  '便管':     code: '14', tag: '便潜血'
  '咽拭子':   code: '15'
  '黄色采血管（3）': code: '16', tag: '过敏源'
  '蓝色采血管':  code: '17',     tag: '凝血'
  '紫色采血管（2）': code: '18', tag: '基因检测'
  '尿早早孕检测': code: '19',    tag: '早孕检测'
  '基因检测口腔标本盒': code: '20'
  '基因检测唾液标本盒': code: '21'
  '早餐': code: '22'
  '放射科影像':  code: '80'
  'HBV知情书':   code: '99'

for name, vessel of vessels when vessel.tags
  vessel.tags = vessel.tags.reduce (memo, v) ->
    memo[v.departments.sort((a, b) -> if a>b then 1 else -1).join('')] = v.tag
    memo
  , {}

