# Description:
#   Driver for database access through Jarvis
#
# Dependencies:
#   mongodb
#
# Configuration:
#   COURSESHARK_MONGODB_URI must be the auth-included uri of the DB to connect to
#
# Commands:
#   db - Display the current connection status
#
# Author:
#   jrundquist

url   = require 'url'
mongo = require 'mongodb'


collections = []


collectionResponses = [
  'Seems our database has'
  'I know we are tracking'
  'We collect...'
]
countResponses = [
  'I was able to find'
  'I found'
  'By my last count we have'
  'Humm... seems like there are'
  'It seems there are'
  'I know of'
]
module.exports = (robot) ->

  # Log error and return if no URI specified
  if not process.env.COURSESHARK_MONGODB_URI
    robot.logger.error 'COURSESHARK_MONGODB_URI variable not set'
    return

  # Parse the information from the passed monog uri
  info = url.parse process.env.COURSESHARK_MONGODB_URI
  database = (info.path||'').replace /^\//, ''
  if info.auth
    auth = info.auth.split ':'
    info.auth = username: auth[0]
    info.auth.password = auth[1] or ""

  # Create the server and database object
  server = new mongo.Server info.hostname, info.port or 27017
  robot.db = db = new mongo.Db database, server, w: 1

  # Open and authenticate the db
  db.open (err, db) ->
    return robot.logger.error err if err
    if info.auth
      db.authenticate info.auth.username, info.auth.password, (err, val) ->
        return robot.logger.error err if err
        robot.logger.log 'Connected to MongoDB'
    else
      robot.logger.log 'Connected to MongoDB'

    db.collectionNames namesOnly: 1, (err, list) ->
      return robot.logger.error err if err
      collections = list.map (name) -> name.replace "#{db.databaseName}.", ""

  # On exit close the database
  process.on 'exit', ->
    robot.db?.close?()

  #
  robot.respond /db\s*(:?help)?\s*$/i, (msg) ->
    msg.send [
      'db | db help - List this help message'
      'db count <collection> - Returns count of elements in <collection>'
      'db collections - Lists the collections we know of'
    ].join("\n")


  robot.respond /db collections/, (msg) -> returnCollectionsList(msg)
  robot.hear /^what collections/, (msg) -> returnCollectionsList(msg)


  robot.respond /db count ([a-z]+)/i, (msg) -> returnCount(msg)
  robot.hear /how many ([^\s]+)/i, (msg) -> returnCount(msg)




  ### Methods defined here so that we can reuse them under aliases ###

  returnCollectionsList = (msg) ->
    msg.send (msg.random collectionResponses), collections.join("\n")


  returnCount = (msg) ->
    collectionName = msg.match[1]
    if collectionName not in collections
      msg.send "'#{collectionName}' is not a collection in the database"
      return
    robot.db.collection "#{collectionName}", (err, collection) ->
      collection.count {}, (err, count) ->
        return msg.send JSON.stringify err if err
        msg.send ( msg.random countResponses ) + " #{count} #{collectionName}"

  @