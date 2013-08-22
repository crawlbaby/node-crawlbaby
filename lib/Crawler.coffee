_ = require 'underscore'
async = require 'async'

Page = require './Page'

class Crawler
  constructor: (@config) ->
    null

  crawl: (callback) ->
    async.map @config.sites
    ,
      (site, callback) ->
        async.map site.categories
        ,
          (category, callback) ->
            page = new Page()
            page.loadUrl category.entryUrl, (err) ->
              return callback err  if err?

              crawlFields page.$.root(), category.fields, callback
        ,
          callback
    ,
      callback 


crawlNextPage = (parentTag, fields, nextPageSelector, resultsArray, callback) ->
  console.log "crawlNextPage started."
  console.log fields
  crawlFields parentTag, fields, (err, results) ->
    return callback err  if err?

    for result in results
      resultsArray.push result

    nextPageTags = parentTag.find(nextPageSelector)
    return callback null, resultsArray  if nextPageTags.length is 0

    nextPageTag = nextPageTags.eq(0)
    nextPageUrl = nextPageTag.attr('href')
    console.log nextPageUrl
    nextPage = new Page()
    nextPage.loadUrl nextPageUrl, (err) ->
      return callback err  if err?
      crawlNextPage nextPage.$.root(), fields, nextPageSelector, resultsArray, callback


crawlFields = (parentTag, fields, callback) ->
  console.log "crawlFields started."
  console.log fields
  fieldKeys = _.keys fields

  async.map fieldKeys
  ,
    (fieldKey, callback) ->
      field = fields[fieldKey]
      console.log "field: #{JSON.stringify field}"
      tags = parentTag.find(field.selector)
      console.log "tags: #{JSON.stringify tags}"

      if tags.length is 0
        return callback null, null

      async.map [0...tags.length]
      ,
        (tagIndex, callback) ->
          tag = tags.eq(tagIndex)

          switch field.type
            when 'nextPage'
              console.log "crawlNextPage parentTag, field.fields, field.selector, [], callback"
              console.log "crawlNextPage #{parentTag}, #{field.fields}, #{field.selector}"
              crawlNextPage parentTag, field.fields, field.selector, [], callback

            when 'page'
              newPageUrl = tag.attr('href')
              console.log newPageUrl
              newPage = new Page()
              newPage.loadUrl newPageUrl, (err) ->
                return callback err  if err?                
                crawlFields newPage.$.root(), field.fields, callback

            when 'tag'
              crawlFields tag, field.fields, callback
            when 'text'
              callback null, tag.text()
            when 'class'
              callback null, tag.attr('class')
            else
              callback null, tag.text()
      ,
        (err, results) ->
          return callback err  if err?

          if results.length is 1
            callback null, results[0]
          else
            callback null, results
  ,
    (err, results) ->
      return callback err  if err?

      resultMap = {}
      for result, index in results
        resultMap[fieldKeys[index]] = result
      callback null, resultMap


module.exports = Crawler
