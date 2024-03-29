# Description:
#   Hubot delivers a pic from Reddit's /r/aww frontpage
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   aww - Display the picture from /r/aww
#
# Author:
#   eliperkins, jrundquist

module.exports = (robot) ->
  robot.hear /aww+/i, (msg) ->
    search = escape(msg.match[1])
    msg.http('http://www.reddit.com/r/aww.json')
      .get() (err, res, body) ->
        result = JSON.parse(body)

        if result.data.children.count <= 0
          msg.send "Couldn't find anything cute..."
          return

        urls = [ ]
        for child in result.data.children
          urls.push(child.data.url)

        msg.send msg.random urls
