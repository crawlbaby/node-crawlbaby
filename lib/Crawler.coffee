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


crawlFields = (parentTag, fields, callback) ->
  fieldKeys = _.keys fields

  async.map fieldKeys
  ,
    (fieldKey, callback) ->
      field = fields[fieldKey]
      tags = parentTag.find(field.selector)

      if tags.length is 0
        return callback null, null

      async.map [0...tags.length]
      ,
        (tagIndex, callback) ->
          tag = tags.eq(tagIndex)

          switch field.type
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
            when 'nextPage'
              newPageUrl = tag.attr('href')
              console.log newPageUrl
              newPage = new Page()
              newPage.loadUrl newPageUrl, (err) ->
                return callback err  if err?
                crawlFields newPage.$.root(), fields, callback
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
