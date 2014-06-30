moment = require "moment"

module.exports = (record_schema) ->
  # 根据身份证号同步年龄
  # 更新客户身份标识
  # 为了优化数据模式，在团体批量注册时，无需击多次MongoDB根据批次编号
  # 检索公司名称，故：允许在保存前预先设置`source`键，辅助`source_safe`键
  # 进行标示。
  # 由于customer_key已在项目多处使用过，且暂时不删除
  record_schema.pre 'save', on, (next, done) ->
    next()
    if @appeared.length
      @profile.check_date = @appeared[0]
      for order in @orders
        # 如果订单日期小于第一次到场日期
        # 则将第一次到场日期赋给订单日期
        for history in order.histories
          if history.date_string < @appeared[0]
            history.date_string = @appeared[0]
            history.date_number = moment(@appeared[0]).valueOf()
    if @profile.id
      birthday     = @model('Record').getBirthday @profile.id
      age = moment(@profile.check_date).format('YYYY') - birthday.split('-')[0]
      @profile.age  = if (moment(birthday).add("y", age) > moment(@profile.check_date)) then age - 1 else age
      @customer_key = @customer_key1 = "#{birthday}|#{@profile.sex}|#{@profile.name}"
    else
      @customer_key1 = undefined
    if @profile.source_safe
      delete @profile.source_safe
      done()
    else
      return done() unless @isModified('profile')
      if @profile.batch
        @model('Batch').findById(@profile.batch)
        .select('company')
        .exec (err, data) =>
          return done err if err
          return done() unless data
          @profile.source = data.company
          @profile.division = '' if @profile.division is '其他'
          @customer_key = @customer_key2 = "#{@profile.source}|#{@profile.sex}|#{@profile.name}" unless @profile.id
          done()
      else
        @profile.source = "个检"
        @customer_key = @customer_key2 = "#{@profile.source}|#{@profile.sex}|#{@profile.name}" unless @profile.id
        done()
