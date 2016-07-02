# Description
#   Have an office dart fight, even when working from home
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   *`bat shoot <username> (in the legs/head)`* - Fires a foam dart
#   *`bat score <username>`* - Get Score
#
# Notes:
#   None
#
# Author:
#   bsensale

Url   = require "url"
Redis = require "redis"


module.exports = (robot) ->
# check for redistogo auth string for heroku users
# see https://github.com/hubot-scripts/hubot-redis-brain/issues/3
  info = Url.parse process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379'
  if info.auth
    client = Redis.createClient(info.port, info.hostname, {no_ready_check: true})
    client.auth info.auth.split(":")[1], (err) ->
      if err 
        robot.logger.error "darts: Failed to authenticate to Redis"
      else
        robot.logger.info "darts: Successfully authenticated to Redis" 
  else
    client = Redis.createClient(info.port, info.hostname)




  robot.respond /shoot ((.+)(?: in the )(head|body|legs)?|(.*))/i, (msg) ->

    victimStr = msg.match[2] ? msg.match[4]
    victimStr = victimStr.substr(1) if victimStr.charAt(0) is '@'

    users = robot.brain.usersForFuzzyName(victimStr)
    if users.length > 1
      msg.reply "Be more specific; I can't shoot more than one person at once!"
      return
    victim = if users.length is 1 then users[0] else null

    if not victim
      msg.reply "You want me to shoot someone who doesn't exist.  You are strange."
      return

    
    aim = msg.match[3]
    if not aim
      aim = msg.random ["head", "body", "legs"]
    target = msg.random ["#{aim}", "#{aim}", "#{aim}", "#{aim}", "miss", "miss"]
    
    if (victim.name == "ajmendez")
      target = "miss"
      victimName = msg.message.user.name
      msg.reply "I can't do that dave..."
      return
    else
      victimName = victim.name
      msg.reply "Target acquired."
    
    result = (target) ->
      if target is "miss"
        "The shot sails safely overhead."
      else if target is "head"
        msg.random [
          "It hits #{victimName} right in the eye!  You monster!",
          "It bounces right off #{victimName}'s nose.",
          "It hits #{victimName} in the ear.  Why would you do that?",
          "POW!  BANG!  #{victimName} is hit right in the kisser!",
          "Right in the temple.  #{victimName} falls limp to the floor."
        ]
      else if target is "body"
        msg.random [
          "The shot bounces off #{victimName}'s shoulder.",
          "It hits #{victimName} right in the chest.  #{victimName} has trouble drawing their next breath.",
          "The dart hits #{victimName} in the stomach and gets lodged in their belly button.",
          "It hits #{victimName} in the back, causing temporary paralysis.",
          "The dart bounces off #{victimName}'s left shoulder, spinning them violently around."
        ]
      else if target is "legs"
        msg.random [
          "The dart smacks into #{victimName}'s thigh.  Charlie Horse!!!",
          "The dart hits #{victimName} square in the crotch.  I need an adult!",
          "It hits #{victimName} right in the kneecap.  What did they owe you money?",
          "It smacks into #{victimName}'s pinkie toe.  They go wee wee wee all the way home!",
          "The dart hits right on #{victimName}'s shin, knocking them to the ground"
        ]

    msg.emote "fires a foam dart at #{victimName}'s #{aim}.  #{result target}"
    
    username = msg.message.user.name
    client.get "sent:dartScore", (err, reply) ->
      if err
        robot.emit 'error', err
      else if reply
        sent = JSON.parse(reply.toString())
      else
        sent = {}

      sent[username] = {hit: 0, miss: 0, total: 0, average: 0, beenhit:0, beenmiss:0, beenshotat:0} if !sent[username] or !sent[username].beenshotat
      sent[username].hit += if (target != "miss") then 1 else 0
      sent[username].miss += if (target == "miss") then 1 else 0
      sent[username].total += 1
      sent[username].average = sent[username].hit / sent[username].total
      
      sent[victimName] = {hit: 0, miss: 0, total: 0, average: 0, beenhit:0, beenshotat:0} if !sent[victimName] or !sent[victimName].beenshotat
      sent[victimName].beenhit += if (target != "miss") then 1 else 0
      sent[victimName].beenmiss += if (target == "miss") then 1 else 0
      sent[victimName].beenshotat += 1
      

      client.set "sent:dartScore", JSON.stringify(sent)
      # msg.emote JSON.stringify(sent)

  robot.respond /score (.*)/i, (msg) ->
    username = msg.match[1]
    # msg.emote "DEBUG #{username}"
    client.get "sent:dartScore", (err, reply) ->
      if err
        robot.emit 'error', err
      else if reply
        # msg.emote reply.toString()
        sent = JSON.parse(reply.toString())
        if username != "everyone" and (!sent[username] or sent[username].average == undefined)
          msg.send "#{username} has no data"
        else
          for user, data of sent
            if (user == username or username == "everyone") and data.average != undefined
              msg.send "#{user}: \t\t\t\t Hits: #{data.hit}; Misses: #{data.miss}; Fired at: #{data.beenshotat}; Been Hit: #{data.beenhit}"
      else
        msg.send "I haven't collected data on anybody yet"
