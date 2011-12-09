#!/usr/bin/env ruby
#

require 'rubygems'
require 'bundler'
Bundler.setup

require 'pp'
require 'Getopt/Declare'

require 'mysql2'
require 'lib/mmconfig'
require 'lib/host'
require 'lib/process'
require 'lib/term_printer'
require 'lib/term_input'
require 'lib/command'
require 'lib/pid'
require 'lib/filter'


spec = <<-EOL
  -c, --config <FILE>         Where to find mmtop_config
  -p, --password <pass>       The password used to connect to all DBs
  -u, --user <user>           The user used to connect to all DBs
  -o, --ops                   David's funky ops mode
EOL

args = Getopt::Declare.new(spec)
config = MMTop::Config.new(args)

printer = MMTop::TermPrinter.new
input = MMTop::TermInput.new

while true
  MMTop::PID.reset
  config.get_info
  printer.print_info(config.info)
  input.control(config)
end



