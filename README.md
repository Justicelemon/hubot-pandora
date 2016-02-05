# hubot-pandora

A script that allows hubot to act like a pseudo-filesystem to store important information to share

See [`src/pandora.coffee`](src/pandora.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-pandora --save`

Then add **hubot-pandora** to your `external-scripts.json`:

```json
[
  "hubot-pandora"
]
```

## Commands

```
pandora help - view list of commands
ls (-v|-verbose)? <path?> - View all boxes and contents in provided path. If no paths are provided, the top level boxes and contents are shown. Adding the -v/-verbose flag also shows the intros."
commands_str = "\nmkbox <path> <intro?> - Creates box and sets the intro, if provided."
mkcontent <path> <intro?> - Creates content and sets the intro, if provided."
rm <path> - Removes the box/content at the provided path."
mv <src> <dest> - Moves the box/content at src to dest. Use / as dest to move to the top level"
cp <src> <dest> - Copies the box/content at src to dest. User / as dest to copy to the top level"
pandora (open|view|unbox|cat|show) <path> - View the information stored in the given path if path leads to content"
pandora (intro|description|contact) <path> <string> - Changes the intro, description (content Only) or contact (content only) of the element found in the given path to the given string."
pandora add <path> <string> - Appends given string to given content's items."
pandora remove <item #> <path> - Removes the target item from content."
pandora edit <item #> <path> <string> - Change the targetted item to the given string."
return commands_str
```
