# Requiring this file will immediately execute the process as a CLI program. If
# program matching the current `$0` is found, the program will execute. In all
# cases the process will exit immediately.
require 'config/cli'
Config::CLI.exec
