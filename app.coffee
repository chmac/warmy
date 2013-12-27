fs = require 'fs'
xml2js = require 'xml2js'

parser = new xml2js.Parser()

hitUrls = (urls) ->
  for url in urls
    console.dir url.loc[0]

fs.readFile __dirname + '/sitemaps/sitemap_kilt.xml', (err, data) ->
  parser.parseString data, (err, result) ->
    console.log "Sitemap parsed..."
    #console.dir result.urlset.url[0]
    hitUrls result.urlset.url
