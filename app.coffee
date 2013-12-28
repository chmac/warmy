fs = require 'fs'
xml2js = require 'xml2js'

parser = new xml2js.Parser()

flow = require './flow.coffee'

hitIt = (url, next) ->
  console.log "Just started url %s", url.loc[0]
  setTimeout () ->
    console.log "Just finished url %s", url.loc[0]
    next()
  ,
    Math.floor(Math.random() * 5 + 1) * 100

fs.readFile __dirname + '/sitemaps/sitemap_kilt.xml', (err, data) ->
  parser.parseString data, (err, result) ->
    console.log "Sitemap parsed..."
    flow 3, hitIt, result.urlset.url
