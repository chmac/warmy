# Import and instantiate restify
restify = require "restify" # The core upon which this API is built
server = restify.createServer()

# Enable parsing of requests
server.use restify.bodyParser()

async = require 'async'

request = require 'request'

urlParser = require 'url'

config = require './config.coffee'

# Handle PURGE requests
server.get '.*', (req, res, next) ->
  console.log 'Purge request received'
  console.dir req.headers.host
  console.dir req.url
  res.send 200, 'Will do'
  next()

# Start the server and log where it's running
close = server.listen 8000, ->
  console.log "%s listening at %s on %s", server.name, server.url, require('os').hostname()
