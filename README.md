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
hubot pandora help - view a more verbose description all available commands
hubot pandora ls <path> - to view all elements in path
hubot pandora mkbox <path> - to create box in path
hubot pandora mkcontent <path> - to create content in path
hubot pandora rm <path> - remove box/content
hubot pandora mv <src> <test> - move the box/content
hubot pandora cp <src> <test> - copy the box/content
hubot pandora open <path-to-content> - view information stored in content
hubot pandora (intro|view|contact) <path> <string> - edits the specified attribute to the given string
hubot pandora add <path-to-content> <string> - adds given string as an item to the given content
hubot pandora edit <item #> <path-to-content> <string> - edits item
hubot pandora remove <item #> <path-to-content> - removes given item, and changes all higher item numbers
```
