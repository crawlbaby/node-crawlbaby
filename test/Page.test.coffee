should = require 'should'

CrawlBaby = require '../index'
Page = CrawlBaby.Page


describe 'Page', ->
  babyAllItemsUrl = 'http://m.target.com/c/baby/-/N-5xtly?type=products'
  babyAllItemsPage = new Page()

  babyItemReviewsUrl = 'http://m.target.com/custom-reviews/92544'
  babyItemReviewsPage = new Page()

  reviewTags = null
  
  describe '.loadUrl(...)', ->
    it 'should be done', (done) ->
      babyAllItemsPage.loadUrl babyAllItemsUrl, (err) ->
        should.not.exist err
        done()

    it 'should be done', (done) ->
      babyItemReviewsPage.loadUrl babyItemReviewsUrl, (err) ->
        should.not.exist err
        done()

  describe '.findLinks(...)', ->
    it 'should be done', ->
      links = babyAllItemsPage.findLinks '.products a.article-link'
      should.exist links
      links.should.not.be.empty

  describe '.findTags(...)', ->
    it 'should be done', ->
      tags = babyItemReviewsPage.findTags '.reviews article'
      should.exist tags
      reviewTags = tags

  describe '.findFieldsFromTag(...)', ->
    it 'should be done', ->
      fields = babyItemReviewsPage.findFieldsFromTag reviewTags.eq(0),
        title:
          selector: '.RRtitle'
          type: 'text'
        date:
          selector: '.review-date'
          type: 'date'
        rating:
          selector: '.ratings-reviews .rating'
          type: 'tag'
        description:
          selector: '.desclamer4reviews'
          type: 'text'
        detailRatings:
          selector: '#review-quality-ratings .author'
          
      should.exist fields
