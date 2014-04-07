fs = require 'fs'

async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

request = require 'request'

urlParser = require 'url'

config = require './config.coffee'

sitemaps = []

# Run each request one at a time, sequentially
doRequests = (target, sitemap, url, callback) ->
  async.eachSeries config.requests, (req, callback) ->
    doRequest target, sitemap, url, req, callback
  , callback


# Make the request...
doRequest = (target, sitemap, url, req, callback) ->
  urlPieces = urlParser.parse url.loc[0]
  req.headers = {} if not req.headers? # req.headers must exist
  req.headers.host = urlPieces.host
  # Need to overwrite both host and hostname
  urlPieces.host = target
  urlPieces.hostname = target
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

# Do the work
# This nasty mess of nested callbacks should be cleaned up, how? #3
work = () ->
  console.log "Sitemaps parsed, let's do some work... :-)"
  async.each config.targets, (target, callback) ->
    console.log "Starting target %s", target
    # Run X sitemaps at once
    async.eachLimit sitemaps, config.concurrency.sitemaps, (sitemap, callback) ->
      # Run X urls at once
      async.eachLimit sitemap, config.concurrency.urls, (url, callback) ->
        doRequests target, sitemap, url, callback
      , callback
    , (err) ->
        console.log "Target %s finished", target
        return callback()
  , (err) ->
      console.log "All targets finished"

# Read the file, parse the XML, and start flow control
async.eachSeries config.sitemaps, (sitemap, callback) ->
  console.log "Reading sitemap file %s", sitemap
  if fs.existsSync sitemap
    fs.readFile sitemap, (err, data) ->
      parser.parseString data, (err, result) ->
        console.log "Sitemap %s parsed...", sitemap
        sitemaps.push result.urlset.url
        callback()
  else
    console.log "ERROR: Sitemap %s does not exist.", sitemap
,
  work
