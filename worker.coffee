cluster = require 'cluster'
numCPUs = require('os').cpus().length
{spawn} = require 'child_process'

if cluster.isMaster
  console.log 'in master cluster process'
  for i in [0...numCPUs]
    cluster.fork()
  cluster.on 'exit', (worker) ->
    console.log 'worker ' + worker.process.pid + ' died. restart...'
    cluster.fork()
else
  require "./workers"
