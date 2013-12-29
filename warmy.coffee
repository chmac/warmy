fs = require 'fs'

async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

request = require 'request'

config = require './config.example.coffee'

sitemaps = []

# Make the request...
doRequest = (target, sitemap, url, req, callback) ->
  console.log "Starting request to target %s for url %s with options %s", target, url.loc[0], JSON.stringify req
  setTimeout () ->
    console.log "Finishing request to target %s for url %s with options %s", target, url.loc[0], JSON.stringify req
    return callback()
  , Math.floor(Math.random() * 5 + 1) * 20

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
