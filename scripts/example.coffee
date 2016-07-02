# Description:
#   Example scripts for you to examine and try out.
#
# Dependencies:
#   "flip": "~0.1.0"
#
# Configuration:
#   None
#
# Commands:
#   *`bat badger`* - badger, badger
#   *`bat fact`*  - Get a bat fact!
#   *`bat fortune`* - Get a fortune
#   *`bat dance`* - Dance Party
#   *`bat catfact`* - 1-800-Cat-Fact
#   *`bat corgi me`* - Get a Corgi
#   *`bat kitten me`* - Get a kitten
#   *`bat [un]flip`* - Rage out
#   
# Notes:
#   None
#  
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

url = require("url")
flip = require("flip")



module.exports = (robot) ->

  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  
  robot.respond /(fortune)( me)?/i, (msg) ->
    msg.http('http://www.fortunefortoday.com/getfortuneonly.php')
       .get() (err, res, body) ->
         msg.reply body
  
  
  robot.hear /bat simplefact/i, (msg) ->
    facts = [
        "Bats can live more than 30 years and can fly at speeds of up to 60 mph. http://www.nature.org/cs/groups/webcontent/@photopublic/documents/media/free-tailed-bats-940x550.jpg",
        "Bats can find their food in total darkness. They locate insects by emitting inaudible high-pitched sounds, 10-20 beeps per second and listening to echoes. http://www.nature.org/cs/groups/webcontent/@web/@about/documents/media/rafinesques-big-eared-bat-940x.jpg",
        "Many bats eat insects. Bats can eat up to 1,200 mosquitoes in an hour and often consume their body weight in insects every night, helping keep bug populations in check. http://www.nature.org/cs/groups/webcontent/@web/@arizona/documents/media/pallid-bat-940x550.jpg",
        "http://www.nature.org/cs/groups/webcontent/@web/@magazine/documents/media/bracken-cave-bats-940x550.jpg",
        "The world’s smallest bat is the bumble bee bat of Thailand, which is smaller than a thumbnail and weighs less than a penny.",
        "The world’s largest bat is the 'flying fox' that lives on islands in the South Pacific. It has a wingspan of up to 6 feet.",
        "http://www.nature.org/cs/groups/webcontent/@photopublic/documents/media/flying-foxes-940x575.jpg",
        "Some bats migrate south for the winter, while others hibernate through the cold winter months. During hibernation, bats can survive in freezing temperatures, even after being encased in ice."
        ]
    msg.emote msg.random facts
  
  robot.respond /aww/i, (msg) ->
    search = escape(msg.match[1])
    msg.http('http://www.reddit.com/r/aww.json')
      .get() (err, res, body) ->
        result = JSON.parse(body)

        urls = [ ]
        for child in result.data.children
          if child.data.domain != "self.aww"
            urls.push(child.data.url)

        if urls.count <= 0
          msg.send "Couldn't find anything cute..."
          return

        rnd = Math.floor(Math.random()*urls.length)
        picked_url = urls[rnd]

        parsed_url = url.parse(picked_url)
        if parsed_url.host == "imgur.com"
          parsed_url.host = "i.imgur.com"
          parsed_url.pathname = parsed_url.pathname + ".jpg"

          picked_url = url.format(parsed_url)

        msg.send picked_url
  
  robot.respond /fact/i, (msg) ->
    search = escape(msg.match[1])
    msg.http('http://www.reddit.com/r/BatFacts.json')
      .get() (err, res, body) ->
        result = JSON.parse(body)

        urls = [ ]
        titles = [ ]
        for child in result.data.children
          if child.data.domain != "self.BatFacts"
            urls.push(child.data.url)
            titles.push(child.data.title)

        if urls.count <= 0
          msg.send "Couldn't find a bat fact..."
          return

        rnd = Math.floor(Math.random()*urls.length)
        picked_url = urls[rnd]
        picked_title = titles[rnd]

        parsed_url = url.parse(picked_url)
        if parsed_url.host == "imgur.com"
          parsed_url.host = "i.imgur.com"
          parsed_url.pathname = parsed_url.pathname + ".jpg"

          picked_url = url.format(parsed_url)

        msg.send "<#{picked_url}|#{picked_title}>"
  
  
  robot.respond /(dance|happy)/i, (msg) ->
    carltons = [
      "http://media.tumblr.com/tumblr_lrzrlymUZA1qbliwr.gif",
      "http://web.archive.org/web/20121119111926/http://3deadmonkeys.com/gallery3/var/albums/random_stuff/Carlton-Dance-GIF.gif",
      "http://gifsoup.com/webroot/animatedgifs/987761_o.gif",
      "http://s2.favim.com/orig/28/carlton-banks-dance-Favim.com-239179.gif",
      "http://gifsoup.com/webroot/animatedgifs/131815_o.gif"
    ]
    
    msg.send msg.random carltons
  
  
  robot.respond /catfact/i, (msg) ->
    msg.http('http://catfacts-api.appspot.com/api/facts?number=1')
          .get() (error, response, body) ->
              # passes back the complete reponse
              response = JSON.parse(body)
              if response.success == "true"
              	msg.send response.facts[0]
              else
              	msg.send "Unable to get cat facts right now."
  
    robot.respond /kitten?(?: me)?$/i, (msg) ->
      msg.send kittenMe()

    robot.respond /kitten?(?: me)? (\d+)(?:[x ](\d+))?$/i, (msg) ->
      msg.send kittenMe msg.match[1], (msg.match[2] || msg.match[1])

    robot.respond /kitten bomb(?: me)?( \d+)?$/i, (msg) ->
      kittens = msg.match[1] || 5
      msg.send(kittenMe()) for i in [1..kittens]

  kittenMe = (height, width)->
    h = height ||  Math.floor(Math.random()*250) + 250
    w = width  || Math.floor(Math.random()*250) + 250
    root = "http://placekitten.com"
    root += "/g" if Math.random() > 0.5 # greyscale kittens!
    return "#{root}/#{h}/#{w}#.png"
  
  
  
  
  robot.respond /corgi me/i, (msg) ->
    msg.http("http://corginator.herokuapp.com/random")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).corgi

  robot.respond /corgi bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    msg.http("http://corginator.herokuapp.com/bomb?count=" + count)
      .get() (err, res, body) ->
        msg.send corgi for corgi in JSON.parse(body).corgis
  
  robot.respond /(rage )?flip( .*)?$/i, (msg) ->
    if msg.match[1] == 'rage '
      guy = '(ノಠ益ಠ)ノ彡'
    else
      guy = '(╯°□°）╯︵'

    toFlip = (msg.match[2] || '').trim()

    if toFlip == 'me'
      toFlip = msg.message.user.name

    if toFlip == ''
      flipped = '┻━┻'
    else
      flipped = flip(toFlip)

    msg.send "#{guy} #{flipped}"


  robot.respond /unflip( .*)?$/i, (msg) ->
    toUnflip = (msg.match[1] || '').trim()

    if toUnflip == 'me'
      unflipped = msg.message.user.name
    else if toUnflip == ''
      unflipped = '┬──┬'
    else
      unflipped = toUnflip

    msg.send "#{unflipped} ノ( º _ ºノ)"
  
  

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
