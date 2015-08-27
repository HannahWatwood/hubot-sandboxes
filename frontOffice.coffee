# Add in a front office module to add and configure a front office on a sandbox
# 
# Commands:
# hubot  Add Front office [Name] [Talent Network ID] [Devolper ID] [Client ID]
# hubot Show/List Front Offices
# hubot Configure Sandbox [sandbox name] [Front Office Name]
# 
# Notes: How do I add in the sandbox module into this?
# Can I connect to the dev mysql  server from here?
# If I can't will be able to when this is dockerized?
# Is there a standard password for connecting?
# Should I store that in a file that builds it, how would I get to it?
#

moment = require 'moment'

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.frontOffice ||= {}
    robot.brain.data.frontOfficeQueue = new SimpleQueue(robot.brain.data.frontOfficeQueue || [])

  robot.respond /(list|show) front Office/i, (msg) ->
    frontOffices = robot.brain.data['frontOffice']

    if Object.keys(frontOffices).length == 0
      return msg.send "Sorry, I don't know about any Front Offices"

    human_speak = (name, meta) ->
      if meta.isFree()
        return "* #{name} is free"
      else
        owner_name = meta.ownerName robot.brain
        return "#{name} is in use by #{owner_name} on #{sandbox_name} as of #{moment(meta.modified_dt).fromNow()}"

    human_text = (human_speak(name, new Sandbox(meta)) for name, meta of sandboxes)

    msg.send "Sandboxes:\n" + human_text.join("\n")

  robot.respond /add frontOffice? ([A-Aa-z0-9-_]+ TN[[A-Aa-z0-9-_]+ )/i, (msg) ->
    frontOffice_name = msg.match[1].toString();
    if robot.brain.data.frontOffice[frontOffice_name]
      return msg.reply "#{frontOffice_name} already exists"
    
   tnId = frontOffice_name = msg.match[2].toString();
   if robot.brain.data.frontOffice[frontOffice_name].tnId
    return msg.reply "#{tnId} already exists"

    robot.brain.data.sandboxes[frontOffice_name] = new frontOffice([owner: null,tnid: tnId, devid: msg.match[3].toString(), clientid: msg.match[4].toString()])
    msg.reply "Done"
  
  robot.respond /Configure Sandbox ([A-Aa-z0-9-_]+ [[A-Aa-z0-9-_]+)/i, (msg) ->


class frontOffice
  constructor: (options) ->
    @owner = options.owner
    @TNID = options.tnid 
    @DevolperID = options.devid
    @ClientId = options.clientid
    @modified_dt = options.modified_dt || new Date()

  isFree: ->
    return not @owner

  OwnerName: (brain) ->
    return "Nobody" unless @owner
    return brain.userForId(@owner).name

  
