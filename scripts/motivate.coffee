# Description:
#   A port of http://motivate.im/
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   *`high five <username>`* - HIGH FIVE!
#   *`bat fivescore <username>`* - F5 Score
#   *`bat five <username>`* - Bat five
#   *`^5 <username>`* - Gives user a high five
#   *`!m <username>`* - Encourages the user
#
# Author:
#   jjasghar
#   !thank <username> - Hubot encourages your user
#   !thanks <username> - Hubot encourages your user


Url   = require "url"
Redis = require "redis"


module.exports = (robot) ->
  
  info = Url.parse process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379'
  if info.auth
    client = Redis.createClient(info.port, info.hostname, {no_ready_check: true})
    client.auth info.auth.split(":")[1], (err) ->
      if err 
        robot.logger.error "high-five: Failed to authenticate to Redis"
      else
        robot.logger.info "high-five: Successfully authenticated to Redis" 
  else
    client = Redis.createClient(info.port, info.hostname)
  
  
  
  robot.hear /^!(m|than(k|ks)) (.+)$/i, (msg) ->
    user = msg.match[3]

    praise = [
        "Keep on rocking, @#{user}!",
        "Keep up the great work, @#{user}!",
        "You're awesome, @#{user}!",
        "You're doing good work, @#{user}!" # Original and inspiration
        ]

    msg.send msg.random praise

  robot.hear /^(high five|bat five)$/i, (msg) ->
      username = msg.message.user.name
      msg.send "high five @#{username}!"
      
      
      client.get "sent:fiveScore", (err, reply) ->
        if err
          robot.emit 'error', err
        else if reply
          sent = JSON.parse(reply.toString())
        else
          sent = {}

        sent[username] = {given: 0, received: 0} if !sent[username] or !sent[username].given
        sent[username].received += 1
      
  robot.hear /^(high five|bat five|!h5|\^5) (.+)$/i, (msg) ->
    userStr = msg.match[2]
    userStr = userStr.substr(1) if userStr.charAt(0) is '@'
    
    users = robot.brain.usersForFuzzyName(userStr)
    if users.length > 1
      msg.reply "Too many fives!"
      return
    
    user = if users.length is 1 then users[0] else null
    
    
    if not user
      msg.reply "You want me to high five someone who doesn't exist.  You are strange."
      return
      
    user = user.name
    fives = [
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "high fives @#{user}!",
        "air fives @#{user}!",
        "Wi fi's @#{user}!",
        "requests the highest of fives from @#{user}",
        "gives @#{user} the highest of fives",
        "gives @#{user} some skin",
        "engages @#{user} in an air five. https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/HFE_Air_Five.JPG/220px-HFE_Air_Five.JPG",
        "Up High @#{user}! https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/HFE_Too_Slow_1.JPG/120px-HFE_Too_Slow_1.JPG",
        "Down Low @#{user}! https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/HFE_Too_Slow_2.JPG/120px-HFE_Too_Slow_2.JPG",
        "Victim @#{user} misses! https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/HFE_Too_Slow_3.JPG/120px-HFE_Too_Slow_3.JPG",
        "Too slow @#{user}! (with finger-guns) https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/HFE_Too_Slow_4.JPG/120px-HFE_Too_Slow_4.JPG"
        ]
    
    msg.emote msg.random fives
    
    username = msg.message.user.name
    client.get "sent:fiveScore", (err, reply) ->
      if err
        robot.emit 'error', err
      else if reply
        sent = JSON.parse(reply.toString())
      else
        sent = {}

      sent[username] = {given: 0, received: 0} if !sent[username] or !sent[username].given
      sent[username].given += 1
      
      sent[user] = {given: 0, received: 0} if !sent[user] or !sent[user].given
      sent[user].received += 1
      
      client.set "sent:fiveScore", JSON.stringify(sent)
      # msg.emote JSON.stringify(sent)
      
      
  robot.respond /fivescore (.*)/i, (msg) ->
    username = msg.match[1]
    # msg.emote "FS @#{username}"
    client.get "sent:fiveScore", (err, reply) ->
      if err
        robot.emit 'error', err
      else if reply
        # msg.emote reply.toString()
        sent = JSON.parse(reply.toString())
        if username != "everyone" and (!sent[username] or sent[username].given == undefined)
          msg.send "@#{username} has no data"
        else
          for user, data of sent
            if (user == username or username == "everyone") and data.given != undefined
              msg.send "@#{user}: \t\t Fives given: #{data.given} and Fives received: #{data.received}"
      else
        msg.send "I haven't collected data on anybody yet"
   
      
    