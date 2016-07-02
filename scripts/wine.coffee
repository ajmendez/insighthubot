# Description:
#   Wineify the text
#
# Dependencies:
#   "natural": "0.4.0"
#   "redis": ">= 0.10.0"
#
# Configuration:
#   REDISTOGO_URL
#
# Commands:
#   *`bat wine <message>`*
#
# Notes:
#   All text spoken and not directed to hubot will be scored against the sentimental database
#    and a running average will be saved.
#   You can use the "check on" commands to look up current averages for the different users.

Natural = require "natural"
Url   = require "url"
Redis = require "redis"

module.exports = (robot) ->

# check for redistogo auth string for heroku users
# see https://github.com/hubot-scripts/hubot-redis-brain/issues/3
  # info = Url.parse process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379'
  # if info.auth
  #   client = Redis.createClient(info.port, info.hostname, {no_ready_check: true})
  #   client.auth info.auth.split(":")[1], (err) ->
  #     if err
  #       robot.logger.error "hubot-wine: Failed to authenticate to Redis"
  #     else
  #       robot.logger.info "hubot-sentimental: Successfully authenticated to Redis"
  # else
  #   client = Redis.createClient(info.port, info.hostname)

  # robot.hear /(.*)/i, (msg) ->
  #   spokenWord = msg.match[1]
  #   if spokenWord and spokenWord.length > 0 and !new RegExp("^" + robot.name).test(spokenWord)
  #     analysis = analyze spokenWord
  #     username = msg.message.user.name
  #
  #     client.get "sent:userScore", (err, reply) ->
  #       if err
  #         robot.emit 'error', err
  #       else if reply
  #         sent = JSON.parse(reply.toString())
  #       else
  #         sent = {}
  #
  #       sent[username] = {score: 0, messages: 0, average: 0} if !sent[username] or !sent[username].average
  #       sent[username].score += analysis.score
  #       sent[username].messages += 1
  #       sent[username].average = sent[username].score / sent[username].messages
  #
  #       client.set "sent:userScore", JSON.stringify(sent)
  #
  #       if analysis.score < -2 and not process.env.HUBOT_SENTIMENTAL_QUIET?
  #         msg.send "stay positive #{msg.message.user.name}"
  #
  #       robot.logger.debug "hubot-sentimental: #{username} now has #{sent[username].score} / #{sent[username].average}"

  robot.respond /wine ?(.*)/i, (msg) ->
    text = msg.match[2]
    username = msg.message.user.name
    
    intro = msg.random ["*OK #{username}!*",
                        "_What's Up #{username}?_",
                        "*BOO* YA _#{username}_!",
                        "_OH YEAAAHHHH #{username}_"]
    
    second = msg.random ["Twenty bucks on *this*:",
                         "_Listen to this:_",
                         "Go ahead. *GET TOTALLY NUTS:*",
                         "... `wait for it` ...",
                         ""]
    
    msg.send intro
    msg.send second
    if text
      msg.send text
    


# wineFormat (msg, text) ->
#   response = "XXX"
#   cb response
    