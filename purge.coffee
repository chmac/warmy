http = require 'http'

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
    console.log "INFO: Starting PURGE target %s", target
    doRequests target, sitemap, url, callback
  , (err) ->
      console.log "INFO: All PURGE targets finished"

# Send a response as JSON
sendResponse = (res, status, obj) ->
  code = parseInt status
  # Make sure status code is really an integer, crude test
  if code is Number.NaN
    code = 200
  res.writeHead code,
    'Content-type': 'application/json'
  res.write JSON.stringify obj
  res.end()

# Handle PURGE requests
requestPurge = (req, res) ->
  if not req.headers?.host?
    return sendResponse res, 400, 'Missing Host'
  doUrl req.headers.host, req.url
  sendResponse res, 200, 'Will do'

# Handle GET requests
requestGet = (req, res) ->
  if req.url is '/ping'
    sendResponse res, 200, 'pong'
  else
    sendResponse res, 404, 'Not found'

# Handle all requests
onRequest = (req, res) ->
  console.log 'DEBUG: Request received for host %s url %s with method %s', req.headers.host, req.url, req.method
  switch req.method
    when 'PURGE' then requestPurge req, res
    when 'GET' then requestGet req, res
    else
      sendResponse res, 501, 'Not Implemented'

# Boot the server on port 8080
server = http.createServer onRequest
server.listen 8080, '127.0.0.10', ->
  console.log 'INFO: PURGE forwarder started on IP %s port %s on host %s.', server.address().address, server.address().port, require('os').hostname()
