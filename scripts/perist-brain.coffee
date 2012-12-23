# Description:
#   Interacts with the Google Maps API.
#
# Commands:
#   hubot brain - Shows the working brain. optional [save|load|lobotomy]

url   = require "url"
redis = require 'redis'

module.exports = (robot) ->

  redisLocation   = url.parse process.env.JARVIS_REDIS_STORE || '`'
  client = redis.createClient(redisLocation.port, redisLocation.hostname)
  client.auth info.auth.split(":")[1] if redisLocation.auth

  client.on "error", (err) ->
    robot.logger.error err

  client.on "connect", ->
    robot.logger.debug "Connected to Redis"
    loadBrain()

  loadBrain = ->
    return if not client
    client.get "hubot:storage", (err, reply) ->
      if err then robot.logger.error err
      if reply then robot.brain.mergeData JSON.parse(reply.toString())

  robot.brain.on 'save', (data) ->
    client.set 'hubot:storage', JSON.stringify data

  robot.brain.on 'close', ->
    client.quit()

  robot.respond /brain reload/i, (msg) ->
    msg.send 'woop... lets reload that brain'
    loadBrain()

  robot.respond /brain save/i, (msg) ->
    msg.send 'packing up and saving brain'
    robot.brain.save()

  robot.respond /brain lobotomy/i, (msg) ->
    msg.send 'oh no! not a lobotomy! o.O'
    robot.brain.close()
