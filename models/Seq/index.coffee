mongoose   = require 'mongoose'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

schema =
  # 集合名
  _id: String  #"records"

  # 自动增长值
  seq : Number #1

seqSchema = new Schema(schema, { versionKey: false })

seqSchema.statics.retrieveIdentity = (type, cb) ->
  @findByIdAndUpdate type, {$inc:{seq:1}}, {upsert: true}, (err, data) =>
    return cb err if err
    cb null, data.seq

seqSchema.statics.retrieveBarcode = (type, cb) ->
  @retrieveIdentity type, (err, identity) => 
    return cb err if err
    cb null, @identity_to_barcode identity

seqSchema.statics.retrieveSeq = (type, num, cb) ->
  return cb() unless num
  @findByIdAndUpdate type, {$inc:{seq:num}}, {upsert: true}, (err, data) =>
    return cb err if err
    cb null, data.seq

seqSchema.statics.identity_to_barcode = (identity) ->
  barcode = "#{identity}"
  barcode = "0#{barcode}" if barcode.length % 2
  barcode = "00#{barcode}" while barcode.length < 8
  barcode

module.exports = seqSchema
