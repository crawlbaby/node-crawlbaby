request = require 'request'
cheerio = require 'cheerio'


class Page
  requestHeader:
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.'
    # 'Accept-Encoding': 'gzip,deflate,sdch'
    'Accept-Language': 'en-US,en;q=0.8'
    'Cache-Control': 'no-cache'
    'Connection': 'keep-alive'
    # 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'


  loadUrl: (@url, options, callback) ->
    if typeof options is 'function'
      callback = options
      options = {}

    options.url = url
    options.header = @requestHeader  if not options.header?

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
