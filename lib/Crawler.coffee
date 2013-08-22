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

              crawlFields page, page.$.root(), category.fields, callback
        ,
          callback
    ,
      callback 


crawlNextPage = (page, parentTag, fields, nextPageSelector, resultsMap, callback) ->
  crawlFields page, parentTag, fields, (err, results) ->
    return callback err  if err?

    for k, v of results
      resultsMap[k] = []  if not resultsMap[k]?

      for item in v
        resultsMap[k].push item

    nextPageTags = parentTag.find(nextPageSelector)
    return callback null, resultsMap  if nextPageTags.length is 0

    nextPageTag = nextPageTags.eq(0)
    nextPageUrl = nextPageTag.attr('href')
    console.log nextPageUrl
    nextPage = new Page()
    nextPage.loadUrl nextPageUrl, (err) ->
      return callback err  if err?
      crawlNextPage nextPage, nextPage.$.root(), fields, nextPageSelector, resultsMap, callback


crawlFields = (page, parentTag, fields, callback) ->
  fieldKeys = _.keys fields

  async.map fieldKeys
  ,
    (fieldKey, callback) ->
      field = fields[fieldKey]
      tags = parentTag.find(field.selector)

      if tags.length is 0 or not tags?
        switch field.type
          when 'nextPage'
            return crawlNextPage page, parentTag, field.fields, field.selector, {}, callback
          when 'url'
            return callback null, page.url
          else
            return callback null, null

      async.map [0...tags.length]
      ,
        (tagIndex, callback) ->
          tag = tags.eq(tagIndex)

          switch field.type
            when 'nextPage'
              crawlNextPage page,parentTag, field.fields, field.selector, {}, callback

            when 'page'
              newPageUrl = tag.attr('href')
              console.log newPageUrl
              newPage = new Page()
              newPage.loadUrl newPageUrl, (err) ->
                return callback err  if err?                
                crawlFields newPage, newPage.$.root(), field.fields, callback

            when 'tag'
              crawlFields page, tag, field.fields, callback
            when 'text'
              callback null, tag.text()
            when 'class'
              callback null, tag.attr('class')
            else
              callback null, tag.text()
      ,
        (err, results) ->
          return callback err  if err?

          if results.length is 1 and typeof results[0] is 'string'
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
