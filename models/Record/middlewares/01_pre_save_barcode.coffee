Hashids = require("hashids")

module.exports = (record_schema) ->
  # 确保新增档案时，生成25码，存在25码和修改档案时均不生成。
  record_schema.pre 'save', on, (next, done) ->
    next()
    if @barcode
      hashids = new Hashids "this is my salt", 0, "0123456789abcdef"
      @profile.hash_id = hashids.encrypt parseInt @barcode
      return done()
    # TODO: 简化
    @model('Seq').retrieveBarcode 'records', (err, barcode) =>
      return done err if err
      @barcode = barcode
      hashids = new Hashids "this is my salt", 0, "0123456789abcdef"
      @profile.hash_id = hashids.encrypt parseInt @barcode
      done()
