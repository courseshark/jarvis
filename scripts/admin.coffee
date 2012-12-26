# Description:
#   Jarvis permissions
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   give [userId] permission [permissionGroup] - Add user to permission group
#   remove permission [permissionGroup] from [userId] - Remove user from permission group
#
# Author:
#   jrundquist

module.exports = (robot) ->

  robot.brain.data.permissions = robot.brain.data.permissions or {admin: []}

  robot.respond /give ([^\s]+) permission (?:to\s)?([^$]+)$/i, (msg) ->
    if msg.message.user.id not in robot.brain.data.permissions['admin']
      if msg.message.user.id isnt 'jrscienceguy@gmail.com'
        return msg.send 'You dont have permission to do that'
    permission = msg.match[2].replace /\s/g, '-'
    robot.brain.data.permissions[permission] = robot.brain.data.permissions[permission] or []
    robot.brain.data.permissions[permission].push msg.match[1]
    msg.send "#{msg.match[1]} is now in permission group '#{permission}'"
    robot.brain.save()

  robot.respond /remove permission ([^\s]+) from ([^$]+)$/i, (msg) ->
    if msg.message.user.id not in robot.brain.data.permissions['admin']
      if msg.message.user.id isnt 'jrscienceguy@gmail.com'
        return msg.send 'You dont have permission to do that'
    permission = msg.match[1].replace /\s/g, '-'
    if msg.match[2] not in (robot.brain.data.permissions[permission] or [])
      return msg.send "#{msg.match[2]} not in permission group #{permission}"
    robot.brain.data.permissions[permission] = robot.brain.data.permissions[permission].filter (user) -> user isnt msg.match[2]
    msg.send "#{msg.match[2]} has been removed from permission group '#{permission}'"
    robot.brain.save()