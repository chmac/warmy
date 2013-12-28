fs = require 'fs'

xml2js = require 'xml2js'
parser = new xml2js.Parser()

request = require 'request'

# Apparently _ doesn't work in coffee http://stackoverflow.com/a/10974072/198232
__ = require 'underscore'

# Load the config
config = require './config.example.coffee'

# Our flow control module
flow = require './flow.coffee'

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

# Read the file, parse the XML, and start flow control
fs.readFile __dirname + '/sitemaps/sitemap.xml', (err, data) ->
  parser.parseString data, (err, result) ->
    console.log "Sitemap parsed..."
    flow 3, hitIt, result.urlset.url
