mongodb = require 'mongodb'
{ObjectID} = mongodb
batch_ids = """520995ba2b7b70028500001c
51f7186ccba8498e17000004
51dcbf14b499e6824a00000c
51da73450812d95a10000007
51c7bd6136c411d21c000006
51c03c87b176cd9444000005
51bd6ff5633568311b000004
51b18ecff1ae2f135c000007
51b2ffe84d19a3d21600000b
51ac056bfa2e62ca48000005""".split('\n').map (b) ->
  ObjectID b
mongodb.connect 'mongodb://localhost/hswk', (err, client) ->
  records = client.collection 'records'
  records.remove {'profile.batch': '$in': batch_ids}, (err, res) ->
    console.log err, res
