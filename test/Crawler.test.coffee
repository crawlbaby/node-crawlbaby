should = require 'should'

CrawlBaby = require '../index'
Crawler = CrawlBaby.Crawler

fs = require 'fs'


describe 'Crawler', ->
  config = JSON.parse fs.readFileSync "#{__dirname}/testConfig.json"
  crawler = new Crawler config
  
  describe '.crawl(...)', ->
    it 'should be done', (done) ->
      crawler.crawl (err, results) ->
        should.not.exist err
        console.log JSON.stringify results
        done()
