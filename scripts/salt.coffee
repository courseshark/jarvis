# Description:
#   Jarvis script to run  and return their results
#
# Dependencies:
#   ssh2
#
# Configuration:
#   SALT_SERVER_HOST
#   SALT_SERVER_USER
#   SALT_SERVER_PASSPHRASE
#   SALT_SERVER_PRIVATE_KEY
#
# Commands:
#   salt ping - pings the servers.
#
# Author:
#   jrundquist

ssh = require 'ssh2'

saltServer       = process.env.SALT_SERVER_HOST or 'svr-cerebro.courseshark.com'
serverUser       = process.env.SALT_SERVER_USER or 'root'
serverPassphrase = process.env.SALT_SERVER_PASSPHRASE or ''
serverPrivateKey = process.env.SALT_SERVER_PRIVATE_KEY or undefined

module.exports = (robot) ->

  connection = new ssh()
  connection.on 'connect', ->
    robot.logger.debug 'Connected to Salt Server'
  connection.on 'banner', (msg, lang) ->
    robot.logger.debug "Salt Server Said #{msg}"
  connection.on 'keyboard-interactive', (name, instructions, lang, prompts, next) ->
    console.log arguments
    next();
  connection.on 'ready', ->
    robot.logger.debug 'Connection to Salt Server Ready'
  connection.on 'error', (err) ->
    robot.logger.error JSON.stringify err
  connection.on 'close', ->
    robot.logger.debug 'Connection to Salt Server Closed'

  # Connect to the server
  connection.connect host: saltServer, username: serverUser, privateKey: serverPrivateKey, passphrase: 'ru440417', pingInterval: 1000*60, tryKeyboard: true

  # On exit close the database
  process.on 'exit', ->
    robot.logger.debug "Closing connection to Salt Server"
    connection.end()

  _executeOnServer = (cmd, msg, next=((buffer)->msg.send buffer)) ->
    buffer = ''
    connection.exec cmd, (err, stream) ->
      if err
        return robot.logger.error JSON.stringify err
      stream.on 'data', (data, extended) ->
        buffer += data
      stream.on 'end', () ->
        next buffer

  robot.respond /salt ping/i, (msg) ->
    msg.send 'Pinging...'
    _executeOnServer 'salt "*" test.ping', msg

  robot.respond /salt update/i, (msg) ->
    msg.send 'Let me see what packages are set for update...'
    _executeOnServer 'salt "*" pkg.list_upgrades', msg, (buffer) ->
      try
        buffer = buffer.trim()
        buffer = buffer.replace /([a-z0-9\_\-]+):\s*\{/ig, "'$1':{"
        buffer = buffer.replace /\n/gi, ','
        buffer = buffer.replace /'/g, '"'
        results = JSON.parse "{#{buffer}}"
        for server, programs of results
          cnt = 0
          for program, newVersion of programs
            cnt++
          msg.send "#{server} has #{cnt} programs to update"
      catch e
        msg.send e
        msg.send "{#{buffer}}"

