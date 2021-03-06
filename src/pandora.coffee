# Description
#   A script that allows hubot to act like a pseudo-filesystem to store important information to share
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot pandora help - view a more verbose description all available commands
#   hubot pandora ls <path> - to view all elements in path
#   hubot pandora mkbox <path> - to create box in path
#   hubot pandora mkcontent <path> - to create content in path
#   hubot pandora rm <path> - remove box/content
#   hubot pandora mv <src> <test> - move the box/content
#   hubot pandora cp <src> <test> - copy the box/content
#   hubot pandora open <path-to-content> - view information stored in content
#   hubot pandora (intro|view|contact) <path> <string> - edits the specified attribute to the given string
#   hubot pandora add <path-to-content> <string> - adds given string as an item to the given content
#   hubot pandora edit <item #> <path-to-content> <string> - edits item
#   hubot pandora remove <item #> <path-to-content> - removes given item, and changes all higher item numbers
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Yushu Lin <Justicelemon@hotmail.com>

class Pandora
  constructor: (@robot) ->
    this.reload()
    @robot.brain.on 'loaded', =>
      this.reload()

  reload: ->
    @pandora = @robot.brain.get('pandora') || @robot.brain.data.pandora || {elements: {}, shortcuts: {}}

  save: ->
    @robot.brain.set('pandora', @pandora)
    @robot.brain.save()

  newElement: (path, about = undefined, type) ->
    pathAndEnd = @splitPath path
    newPath = pathAndEnd.path
    name = pathAndEnd.end
    parentBox = @travelPath newPath 
    if (not parentBox?)
      return "mkbox: #{newPath} is not a valid box"
    if (parentBox[name]?)
      return "mkbox: #{newPath}/#{name} already exists"
    if (type == 'Box')
      element = new Box
    else if (type == 'Content')
      element = new Content
    if (not element?)
      return "Constructor failed, please contact the developer"
    if (about?)
      element.___intro = about.trim()
    parentBox[name] = element
    @save()
    return "#{name} created"

  delete: (path) ->
    pathAndEnd = @splitPath path
    newPath = pathAndEnd.path
    target = pathAndEnd.end
    parentBox = @travelPath newPath
    if (not parentBox? or not parentBox[target]?)
      return "rm: #{path} box or content not found"
    delete parentBox[target]
    @save()
    return "#{target} deleted"

  showContent: (path) ->
    pathAndEnd = @splitPath path
    newPath = pathAndEnd.path
    end = pathAndEnd.end
    parentBox = @travelPath newPath
    if (not parentBox? or not parentBox[end]? or parentBox[end].___class != 'Content')
      return "#{path} is not content"
    content = parentBox[end]
    resultStr = ""
    resultStr += "\n*Description* - #{content.___description}"
    resultStr += "\n*Contact* - #{content.___contact}"
    resultStr += "\n*Items:*"
    resultStr += "\n#{index+1}. #{value}" for value, index in content.___items
    return resultStr

  change: (path, field, newValue) ->
    pathAndEnd = @splitPath path
    newPath = pathAndEnd.path
    end = pathAndEnd.end
    parentBox = @travelPath newPath
    if (not parentBox? or not parentBox[end]?)
      return "info: #{path} box or content not found"
    parentBox[end][field] = newValue
    @save()
    return "#{path} edited"

  changeContent: (path, field, newValue) ->
    pathAndEnd = @splitPath path
    if (not pathAndEnd?)
      return "#{path} invalid"
    newPath = pathAndEnd.path
    end = pathAndEnd.end
    parentBox = @travelPath newPath
    if (not parentBox? or not parentBox[end]? or parentBox[end].___class != 'Content')
      return "#{path} is not content"
    parentBox[end][field] = newValue
    @save()
    return "#{path} edited"

  itemAction: (path, item, index, action) ->
    pathAndEnd = @splitPath path
    if (not pathAndEnd?)
      return "#{path} invalid"
    newPath = pathAndEnd.path
    end = pathAndEnd.end
    parentBox = @travelPath newPath
    if (not parentBox? or not parentBox[end]? or parentBox[end].___class != 'Content')
      return "#{path} is not content"
    content = parentBox[end]
    if (action == 'add')
      content.___items.push(item)
      @save()
      return "Item added"
    if (not content.___items[index]?)
      return "There is no item #{index+1} in #{path}"
    if (action == 'edit')
      content.___items[index] = item
      @save()
      return "Item edited"
    if (action == 'remove')
      content.___items.splice(index, 1)
      @save()
      return "Item removed"
    return "A line that shouldn't be reached has been reached, please contact the developer"

  transfer: (src, dest, action) ->
    srcPathAndEnd = @splitPath src
    srcPath = srcPathAndEnd.path
    srcEnd = srcPathAndEnd.end
    srcParentBox = @travelPath srcPath
    if (not srcParentBox? or not srcParentBox[srcEnd]?) 
      return "#{src} box or content not found"
    destBox = @travelPath dest
    if (not destBox?)
      return "#{dest} does not lead to a box"
    if (destBox[srcEnd]?)
      return "The name #{srcEnd} is already in use in #{dest}"
    destBox[srcEnd] = @clone srcParentBox[srcEnd], srcParentBox[srcEnd].___class
    response_str = "Successfully copied"
    if (action == 'move')
      delete srcParentBox[srcEnd]
      response_str = "Successfully moved"
    @save()
    return response_str

  travelPath: (path = undefined) ->
    box = @pandora.elements
    if (not path?)
      return box
    boxes = path.split('/')
    for i in boxes
      if i.trim().length > 0
        box = box[i.trim()]
        if (not box? or box.___class != 'Box')
          return undefined
    return box

  splitPath: (path) ->
    boxes = path.split('/')
    end = boxes.pop()
    if (end == undefined)
      return undefined
    while (boxes.length > 0 and end.length == 0)
      end = boxes.pop()
    newPath = boxes.join('/')
    return {end: end, path: newPath}

  clone: (element, type) ->
    if type == 'Box'
      newInstance = new Box
    else if type == 'Content'
      newInstance = new Content
    newInstance.___class = type
    newInstance.___intro = element.___intro
    if type == 'Content'
      newInstance.___description = element.___description
      newInstance.___contact = element.___contact
      newInstance.___items.push(item) for item in element.___items
    return newInstance

  commands: ->
    commands_str = ''
    commands_str += "\n#{@robot.name} pandora ls (-v|-verbose)? <path?> - View all boxes and contents in provided path. If no paths are provided, the top level boxes and contents are shown. Adding the -v/-verbose flag also shows the intros."
    commands_str += "\n#{@robot.name} pandora mkbox <path> <intro?> - Creates box and sets the intro, if provided."
    commands_str += "\n#{@robot.name} pandora mkcontent <path> <intro?> - Creates content and sets the intro, if provided."
    commands_str += "\n#{@robot.name} pandora rm <path> - Removes the box/content at the provided path."
    commands_str += "\n#{@robot.name} pandora mv <src> <dest> - Moves the box/content at src to dest. Use / as dest to move to the top level"
    commands_str += "\n#{@robot.name} pandora cp <src> <dest> - Copies the box/content at src to dest. User / as dest to copy to the top level"
    commands_str += "\n#{@robot.name} pandora (open|view|unbox|cat|show) <path> - View the information stored in the given path if path leads to content"
    commands_str += "\n#{@robot.name} pandora (intro|description|contact) <path> <string> - Changes the intro, description (content Only) or contact (content only) of the element found in the given path to the given string."
    commands_str += "\n#{@robot.name} pandora add <path> <string> - Appends given string to given content's items."
    commands_str += "\n#{@robot.name} pandora remove <item #> <path> - Removes the target item from content."
    commands_str += "\n#{@robot.name} pandora edit <item #> <path> <string> - Change the targetted item to the given string."
    return commands_str

class Box
  constructor: () ->
    @___class = 'Box'
    @___intro = 'No info'

class Content
  constructor: () ->
    @___class = 'Content'
    @___intro = 'Not available'
    @___description = 'Not available'
    @___contact = 'N/A'
    @___items = []


module.exports = (robot) ->
  String::startsWith ?= (s) -> @[...s.length] is s
  pandora = new Pandora robot

  robot.respond /\bpandora ls( -v| -verbose)?( .+)?/i, (res) ->
    box = pandora.travelPath(res.match[2])
    if (box?)
      response_str = ""
      sortedKeys = Object.keys(box).sort()
      for key in sortedKeys
        if !key.startsWith('___')
          response_str += "\n*#{key} (#{box[key].___class})*"
          if (res.match[1]?)
            response_str += " - #{box[key].___intro}"
      res.send response_str
    else
      res.send "Path does not lead to a box"

  robot.respond /\bpandora mkbox ([\w\/-]+)( .+)?$/i, (res) ->
    res.send pandora.newElement res.match[1], res.match[2], 'Box'

  robot.respond /\bpandora mkcontent ([\w\/-]+)( .+)?$/i, (res) ->
    res.send pandora.newElement res.match[1], res.match[2], 'Content'

  robot.respond /\bpandora rm ([\w\/-]+)$/i, (res) ->
    path = res.match[1]
    res.send pandora.delete path

  robot.respond /\bpandora mv ([\w\/-]+) ([\w\/-]+)$/i, (res) ->
    res.send pandora.transfer res.match[1], res.match[2], 'move'

  robot.respond /\bpandora cp ([\w\/-]+) ([\w\/-]+)$/i, (res) ->
    res.send pandora.transfer res.match[1], res.match[2], 'copy'

  robot.respond /\bpandora intro ([\w\/-]+) (.+)$/i, (res) ->
    res.send pandora.change res.match[1], '___intro',res.match[2]

  robot.respond /\bpandora description ([\w\/-]+) (.+)$/i, (res) ->
    res.send pandora.changeContent res.match[1], '___description', res.match[2]

  robot.respond /\bpandora contact ([\w\/-]+) (.+)$/i, (res) ->
    res.send pandora.changeContent res.match[1], '___contact',res.match[2]

  robot.respond /\bpandora( open| view| unbox| cat| show) ([\w\/-]+)$/i, (res) ->
    res.send pandora.showContent res.match[2]

  robot.respond /\bpandora add ([\w\/-]+) (.+)$/i, (res) ->
    res.send pandora.itemAction res.match[1], res.match[2], undefined, 'add'

  robot.respond /\bpandora remove (\d+) ([\w\/-]+)$/i, (res) ->
    res.send pandora.itemAction res.match[2], undefined, res.match[1] - 1, 'remove'

  robot.respond /\bpandora edit (\d+) ([\w\/-]+) (.+)$/i, (res) ->
    res.send pandora.itemAction res.match[2], res.match[3], res.match[1] - 1, 'edit'

  robot.respond /pandora help$/i, (res) ->
    res.send pandora.commands()

