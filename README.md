Topicli
==========
'Small framework to build CLI. It provide simple way to declare options/descriptions/topics to focus only on the "action" part of commands.
Some features:
- Light DSL
- Commands are organised in Topic (aka Subcommands)
- DRY options declaration, it\'s use 3 layers: global -> topic -> command
- Each topic has it\'s own description/options list
- Load options values from a config file
- Built-in Help command: ./cli help TOPIC/COMMAND
- Flexible option-parser, Cli-topic use the stdlib OptionParser by default, but can be changed to Slop/Trollop or any custom one.
- Command suggestions',
