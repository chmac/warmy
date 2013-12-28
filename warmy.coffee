fs = require 'fs'

async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

request = require 'request'

# Load the config
config = require './config.example.coffee'

# Do the heavy lifting...
hitIt = (url, next) ->
  console.log "Just started url %s", url.loc[0]
  results = 0
  requests = 1
  finished = (err, response, body) ->
    if err or response.statusCode isnt 200
      console.log "Error %s with response code %s", err, response.statusCode
    results++
    if results is requests
      console.log "Just finished url %s", url.loc[0]
      next()
  # Do the work here, probably with async requests
  request
    uri: url.loc[0]
    method: 'PURGE'
  ,
    finished
  # Now add more requests with other headers

# Simulate hitting the url for now to test flow logic
hitUrl = (target, url, req, next) ->
  console.log "Starting request to target %s for url %s with options %s", target, url.loc[0], JSON.stringify req
  setTimeout () ->
    console.log "Finishing request to target %s for url %s with options %s", target, url.loc[0], JSON.stringify req
    return next()
  , Math.floor(Math.random() * 5 + 1) * 200

sitemaps = []

# Do the work
# This nasty mess of nested callbacks should be cleaned up, how? #3
work = () ->
  console.log "Sitemaps parsed, let's do some work... :-)"
  async.each config.targets, (target, callback) ->
    console.log "Starting target %s", target
    # Run X sitemaps at once
    async.eachLimit sitemaps, 2, (sitemap, callback) ->
      # Run X urls at once
      async.eachLimit sitemap, 3, (url, callback) ->
        # Run each request one at a time, sequentially
        async.eachSeries config.requests, (req, callback) ->
          # Make the request...
          console.log "Starting request to target %s for url %s with options %s", target, url.loc[0], JSON.stringify req
          setTimeout () ->
            console.log "Finishing request to target %s for url %s with options %s", target, url.loc[0], JSON.stringify req
            return callback()
          , Math.floor(Math.random() * 5 + 1) * 200
        ,
          callback
      ,
        callback
    ,
      (err) ->
        console.log "Target %s finished", target
        return callback()
  ,
    (err) ->
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
