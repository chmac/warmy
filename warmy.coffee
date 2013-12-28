fs = require 'fs'

async = require 'async'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

request = require 'request'

# Apparently _ doesn't work in coffee http://stackoverflow.com/a/10974072/198232
__ = require 'underscore'

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

sitemaps = [
  [
    loc: ['http://buyahipflask.com/']
  ,
    loc: ['http://buyahipflask.com/url2']
  ,
    loc: ['http://buyahipflask.com/url3']
  ]
]

# Read the file, parse the XML, and start flow control
fs.readFile __dirname + '/sitemaps/sitemap.xml', (err, data) ->
  parser.parseString data, (err, result) ->
    console.log "Sitemap parsed..."
    sitemaps.push result.urlset.url
    work()
    # Need the after control flow now...

# After all that
work = () ->
  for target in config.targets
    console.log "Starting target %s", target
    flow 2, sitemaps, null, (sitemap, next) ->
      console.log "Starting on next sitemap..."
      flow 3, sitemap, next, (url, next) ->
        console.log "Just started url %s", url.loc[0]
        flow 1, config.requests, next, (req, next) ->
          hitUrl target, url, req, next
