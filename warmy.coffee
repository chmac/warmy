fs = require 'fs'

async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

request = require 'request'

urlParser = require 'url'

config = require './config.coffee'

sitemaps = []

# Make the request...
doRequest = (target, sitemap, url, req, callback) ->
  urlPieces = urlParser.parse url.loc[0]
  req.headers = {} if not req.headers? # req.headers must exist
  req.headers.host = urlPieces.host
  urlPieces.host = target
  req.url = urlPieces
  console.log "INFO: Starting request to target %s for url %s with options %s", target, urlParser.format(urlPieces), JSON.stringify req
  request req, (err, resp, body) ->
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
        # Run each request one at a time, sequentially
        async.eachSeries config.requests, (req, callback) ->
          doRequest target, sitemap, url, req, callback
        , callback
      , callback
    , (err) ->
        console.log "Target %s finished", target
        return callback()
  , (err) ->
      console.log "All targets finished"

# Read the file, parse the XML, and start flow control
async.each config.sitemaps, (sitemap, callback) ->
  console.log "Reading sitemap file %s", sitemap
  fs.readFile sitemap, (err, data) ->
    parser.parseString data, (err, result) ->
      console.log "Sitemap %s parsed...", sitemap
      sitemaps.push result.urlset.url
      callback()
,
  work
