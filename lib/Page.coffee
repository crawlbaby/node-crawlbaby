request = require 'request'
cheerio = require 'cheerio'


class Page
  requestHeaders:
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.'
    # 'Accept-Encoding': 'gzip,deflate,sdch'
    'Accept-Language': 'en-US,en;q=0.8'
    'Cache-Control': 'no-cache'
    'Connection': 'keep-alive'
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3'


  loadUrl: (@url, options, callback) ->
    if typeof options is 'function'
      callback = options
      options = {}

    options.url = url
    options.headers = @requestHeaders  if not options.headers?
    options.timeout = 100000

    request options, (err, res, @body) =>
      return callback err  if err?

      @$ = cheerio.load body
      callback null, @$


  findTags: (selector) ->
    @$(selector)


  findLinks: (selector) ->
    @getLinksFromTags @findTags selector


  getLinksFromTags: (tags) ->
    links = []

    for tag in tags.toArray()
      if tag.type is 'tag' and tag.name is 'a' and tag?.attribs?.href?
        links.push tag.attribs.href

    links


  findFieldsFromTag: (tag, fields) ->
    results = {}

    for key, field of fields
      fieldTag = tag.find(field.selector)

      switch field.type
        when 'text'
          results[key] = fieldTag.text()
        when 'date'
          results[key] = Date.parse fieldTag.text()
        else
          results[key] = fieldTag

    results



module.exports = Page
