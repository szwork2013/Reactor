pinyin   = require '../../../utils/pinyin.coffee'

module.exports = (record_schema) ->
  # 姓名拼音同步
  record_schema.pre 'save', on, (next, done) ->
    next()
    # console.log @profile.name
    @profile.name_pinyin = pinyin @profile.name
    done()
