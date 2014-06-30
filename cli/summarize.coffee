fairy = require('fairy').connect()
summarization = fairy.queue 'summarization'
# console.log ["hswkzkfy.healskare.com", process.argv[2]]
summarization.enqueue ["test.healskare.com", process.argv[2]], (err, res) ->
  console.log 111111111,3333333333,4444444
  process.exit()
