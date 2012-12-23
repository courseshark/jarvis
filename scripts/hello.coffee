# Description:
#   Just say hello
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Author:
#   jrundquist

helloResponses = [
  'Ahoy'
  'Hi'
  'Hey'
  'Hello'
  'Hello there'
  'How are you?'
  'How are you doing?'
  'How may I help you?'
  'How\'s it going?'
  'Yo'
  'Sup?'
  'Howdy'
  'Welcome'
  'Salutation'
  '*wave* http://goo.gl/a13Nq'
]

module.exports = (robot) ->
  robot.hear /^hell+o|hi|howdy|sup|ahoy|hello|yo\s*$|\*wave\*/i, (msg) ->
    msg.send msg.random helloResponses
