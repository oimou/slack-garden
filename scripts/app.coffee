'use strict'

async        = require 'async'
fs           = require 'fs'
cheerio      = require 'cheerio'
dayInfoArray = []
baseInfoObj = {}

class dayInfo
  constructor:(day) ->
    @dayObj = {}
    @dayObj.date    = day.attr 'data-date'
    @dayObj.dateCnt = day.attr 'data-count' 
    @dayObj.color   = day.attr 'fill'
  getDayData: ->
    return @dayObj

class baseInfo
  constructor: ->
    @baseObj = {}
  calc: ->
    @baseObj.all           = 0 # Year of contributions
    @baseObj.longestStreak = 0
    @LongestStreakArray    = []
    @baseObj.currentStreak = 0
    @CurrentStreakFlag     = false

    for i in [dayInfoArray.length-1 .. 0]
      @baseObj.all += ~~dayInfoArray[i].getDayData().dateCnt
      #console.log dayInfoArray[i].getDayData().dateCnt
      if dayInfoArray[i].getDayData().dateCnt isnt '0'
        # current streak
        if @CurrentStreakFlag is false
          @baseObj.currentStreak++

        # long streak
        @baseObj.longestStreak++
      else
        if i isnt dayInfoArray.length-1
          @CurrentStreakFlag = true
        @LongestStreakArray.push @baseObj.longestStreak
        @baseObj.longestStreak = 0

    @baseObj.longestStreak = Math.max.apply null, @LongestStreakArray
    baseInfoObj = @baseObj


class accessApi
  username = "abouthiroppy"
  url      = "https://github.com/users/#{username}/contributions"
  constructor:(robot) ->
    @robot = robot
  parseContributions: ->
    @robot.http(url)
    .get() (err, res, body) ->
      $ = cheerio.load body
      dayInfoArray = []
      $('svg > g > g > rect').each(()->
        day = $(@)
        dayInfoArray.push(new dayInfo(day))
      )
      base = new baseInfo()
      base.calc()

module.exports = (robot) ->

  date  = new Date
  today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)
  api   = new accessApi robot
  api.parseContributions()

<<<<<<< HEAD
=======
  # notification 
  # debug
  # new cron '* * * * * *', () =>
  #   robot.send {room: "#bot-debug"}, "test3"
  # , null, true, "Asia/Tokyo"
  
  new cron '00 00 21,23 * * *', () =>
    date  = new Date
    today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)
    robot.send {room: '#bot-debug'}, "debug #{today}"
  , null, true, 'Asia/Tokyo'

>>>>>>> 7e7c372... change time
  robot.respond /info$/i, (msg) ->
    msg.send baseInfoObj.all, " ", baseInfoObj.longestStreak, " ", baseInfoObj.currentStreak

  robot.respond /reload$/i, (msg) ->
    api.parseContributions()