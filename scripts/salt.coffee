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
#   salt server(s| status)|what servers are (up|running|on) - Show servers running courseshark
#   salt pull code - pulls latest master branch to all node servers
#   salt update states - runs highstate on all servers ( includes updats to code and restart service )
#   salt (re)start courseshark - restarts the courseshark service
#
# Author:
#   jrundquist

ssh = require 'ssh2'

saltServer       = process.env.SALT_SERVER_HOST or 'svr-cerebro.courseshark.com'
serverUser       = process.env.SALT_SERVER_USER or 'root'
serverPassphrase = process.env.SALT_SERVER_PASSPHRASE or ''
serverPrivateKey = process.env.SALT_SERVER_PRIVATE_KEY or undefined


commandStartingResponses = [
  "I'll get right on that"
  'Ok here we go!'
  "I'll see what I can do"
  'Alright...'
  'One moment...'
  'Lets see...'
]

accessDeniedResponses = [
  'It seems you dont have permission to do that.'
  'You dont have permission to do that'
  'You dont seem to have that authority'
]

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
  serverPrivateKey = require('fs').readFileSync(process.env.HOME+'/.ssh/id_rsa')
  connection.connect host: saltServer, username: serverUser, privateKey: serverPrivateKey, passphrase: serverPassphrase, pingInterval: 1000*60, tryKeyboard: true

  # On exit close the database
  process.on 'exit', ->
    robot.logger.debug "Closing connection to Salt Server"
    connection.end()


  _upDown = (msg) ->
    (buffer) ->
      serversUp = []
      serversDown = []
      for row in buffer.split /\n/
        continue if row is ''
        if row.match /true/i
          serversUp.push row.replace /\:\s+True/g, ''
        else
          serversDown.push row.replace /\:\s+False/, ''
      msg.send "==Servers Up=="
      msg.send serversUp.join("\n") or "None"
      msg.send "==Servers Down=="
      msg.send serversDown.join("\n") or "None"

  _executeOnServer = (cmd, msg, next=((buffer)->msg.send buffer)) ->
    buffer = ''
    connection.exec cmd, (err, stream) ->
      if err
        return robot.logger.error JSON.stringify err
      stream.on 'data', (data, extended) ->
        buffer += data
      stream.on 'end', () ->
        next buffer

  robot.respond /zz/i, (msg) ->


  robot.respond /salt ping/i, (msg) ->
    _executeOnServer 'salt "*" test.ping', msg, _upDown(msg)


  robot.respond /salt server(s| status)|what servers are (up|running|on)/i, (msg) ->
    command = "salt -G 'roles:node' service.restart courseshark"
    _executeOnServer command, msg, upDown(msg)


  robot.respond /salt update states?/i, (msg) ->
    if msg.message.user.id not in (robot.brain.data.permissions['admin'] or [])
      return msg.send msg.random accessDeniedResponses
    msg.send msg.random commandStartingResponses
    msg.send "This may take a sec"
    _executeOnServer 'salt "*" state.highstate', msg


  robot.respond /salt (restart|start) courseshark/i, (msg) ->
    if msg.message.user.id not in (robot.brain.data.permissions['service'] or [])
      return msg.send msg.random accessDeniedResponses
    msg.send msg.random commandStartingResponses
    command = "salt -G 'roles:node' service.restart courseshark"
    _executeOnServer command, msg, (buffer) ->
      everythingOk = true
      # Convert result into english
      for row in buffer.split /\n/
        continue if row is ''
        row = row.replace /'/g, '"'
        row = row.replace /True/g, 'true'
        row = row.replace /False/g, 'false'
        try
          resultObj = JSON.parse row
        catch e
          console.log e, row
          return
        for server, result of resultObj
          if not result
            everythingOk = false
            msg.send "#{server} reports #{result}"
      if everythingOk
        msg.send "All servers reporting success"


  robot.respond /salt (?:pull|laumnch) code/i, (msg) ->
    if msg.message.user.id not in (robot.brain.data.permissions['git-pull'] or [])
      return msg.send msg.random accessDeniedResponses
    msg.send msg.random commandStartingResponses
    command = "salt -G 'roles:node' git.pull /home/courseshark/courseshark opts='--rebase origin master' user=courseshark"
    _executeOnServer command, msg

