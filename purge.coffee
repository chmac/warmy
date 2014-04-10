# Import and instantiate restify
restify = require "restify" # The core upon which this API is built
server = restify.createServer()

# Enable parsing of requests
server.use restify.bodyParser()

async = require 'async'

request = require 'request'

urlParser = require 'url'

config = require './config.coffee'

# Run each request one at a time, sequentially
doRequests = (target, sitemap, url, callback) ->
  async.eachSeries config.requests, (req, callback) ->
    doRequest target, sitemap, url, req, callback
  , (err) ->
    callback err


# Make the request...
doRequest = (target, sitemap, url, req, callback) ->
  urlPieces = urlParser.parse url.loc[0]
  req.headers = {} if not req.headers? # req.headers must exist
  req.headers.host = urlPieces.host
  # Need to overwrite both host and hostname
  urlPieces.host = target
  urlPieces.hostname = target
  # Also overwrite the port
  #delete urlPieces.port
  req.url = urlPieces
  console.log "INFO: Starting request to target %s for url %s with method %s and headers %s", target, urlParser.format(urlPieces), (if req.method? then req.method else null), (if req.headers? then JSON.stringify req.headers else null)
  request req, (err, resp, body) ->
    console.log "INFO: Finished request with code %s to target %s for url %s with method %s and headers %s", resp.statusCode, target, urlParser.format(urlPieces), (if req.method? then req.method else null), (if req.headers? then JSON.stringify req.headers else null)
    if err
      console.log "ERROR: There was an error %s for url %s on target %s with options %s", err, target, url.loc[0], JSON.stringify req
    if resp.statusCode isnt 200
      console.log "ERROR: Response code %s for url %s on target %s", resp.statusCode, url.loc[0], target
      console.log "DEBUG: Response body was %s for request url %s", body, url.loc[0]
    #console.dir resp
    if config.delay?
      setTimeout callback, config.delay
    else
      callback()

doUrl = (host, path) ->
  # Remove port from the hostname
  host = host.substring(0, host.indexOf(':'))
  # Hack these to resemble the data in warmy.coffee
  url = { loc: ['http://' + host + path] }
  sitemap = {}
  async.each config.targets, (target, callback) ->
    console.log "Starting PURGE target %s", target
    doRequests target, sitemap, url, callback
  , (err) ->
      console.log "All PURGE targets finished"

server.get '/ping', (req, res, next) ->
  res.send 200, 'pong'
  next()

server.get '/flush', (req, res, next) ->
  console.log 'Flush called.'
  res.send 200, 'Will do'
  next()

# Handle PURGE requests
server.put '.*', (req, res, next) ->
  console.log 'Purge request received'
  console.dir req.headers.host
  console.dir req.url
  doUrl req.headers.host, req.url
  res.send 200, 'Will do'
  next()

# Start the server and log where it's running
close = server.listen 8000, ->
  console.log "%s listening at %s on %s", server.name, server.url, require('os').hostname()
