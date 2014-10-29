# Description:
#   Icecream screen-maker を叩く
#
# Commands:
#   hubot initialize - part number をクリアしてscreenをTEASERにする
#   hubot part start <part number> - parn <part number> をスタートさせ、screenをMEMBERSにする
#   hubot part set <part number> - parn <part number> にセットするだけ
#   hubot screen <tweet url | TEASER | CONTENTS | MEMBERS | HASH-TAG > - screen 内容を更新する
#
# Author:
#   bobpp
#
child_process = require 'child_process'

module.exports = (robot) ->

  kickScreenMaker = (msg, url) ->
    options =
      cwd: process.env.HUBOT_KICK_SCREEN_CASTER_DIR

    part_id = robot.brain.get("currentPart") or 0
    command = "carton exec perl screen-maker.pl --config " + process.env.HUBOT_KICK_SCREEN_CASTER_CONFIG_PATH +  " --theme " + part_id.toString() + " " + url
    child_process.exec command, options, (error, stdout, stderr) ->
      if !error
        payload =
          message: msg.message
          content:
            text     : "Screen rewrite successful"
            color    : "good"
            fallback : "Screen rewrite successful"
            pretext  : ""

        robot.emit 'slack-attachment', payload
      else
        fields = []
        fields.push
          title: "CMD"
          value: command
          short: false

        fields.push
          title: "ERROR"
          value: error
          short: false

        fields.push
          title: "STDOUT"
          value: stdout
          short: false

        fields.push
          title: "STDERR"
          value: stderr
          short: false

        payload =
          message: msg.message
          content:
            text     : ""
            color    : "danger"
            fallback : "screen rewrite failed"
            pretext  : "Screen rewrite failed"
            fields   : fields

        robot.emit 'slack-attachment', payload

  robot.respond /initialize/i, (msg) ->
    robot.brain.set("currentPart", 0)
    kickScreenMaker msg, "TEASER"

  robot.respond /part set (\d+)/i, (msg) ->
    robot.brain.set("currentPart", parseInt(msg.match[1]))
    msg.send "OK"

  robot.respond /part start (\d+)/i, (msg) ->
    robot.brain.set("currentPart", parseInt(msg.match[1]))
    kickScreenMaker msg, "MEMBERS"

  robot.respond /screen (.*)/i, (msg) ->
    kickScreenMaker msg, msg.match[1]

