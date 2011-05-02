#!/usr/bin/env ruby
#

require 'rubygems'
require 'bundler'
Bundler.setup

require 'pp'
require 'Getopt/Declare'

spec = <<-EOL
  -c, --config <FILE>         Where to find mmtop_config
  -p, --password <pass>       The password used to connect to all DBs
  -u, --user <user>           The user used to connect to all DBs
  -o, --ops                   David's funky ops mode
EOL

args = Getopt::Declare.new(spec)
config_file = args["-c"] || File.join(ENV["HOME"], ".mmtop_config")
config = YAML.load_file(config_file)


