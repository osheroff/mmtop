#!/usr/bin/env ruby
#

require 'rubygems'
require 'bundler'
Bundler.setup

require 'pp'
require 'Getopt/Declare'

require 'mysql2'

spec = <<-EOL
  -c, --config <FILE>         Where to find mmtop_config
  -p, --password <pass>       The password used to connect to all DBs
  -u, --user <user>           The user used to connect to all DBs
  -o, --ops                   David's funky ops mode
EOL

args = Getopt::Declare.new(spec)
config_file = args["-c"] || File.join(ENV["HOME"], ".mmtop_config")
config = YAML.load_file(config_file)

class Config
end

class TermPrinter
  def initialize

  end

  def get_dim
    Curses.program do |scr|
      @x, @y = scr.maxy, scr.maxx
    end
  end

  def print_header
    "+"* @x
  end

  def print_footer
    "-" * @x
  end

  def print_host
  end


  def print(process_collections)
    get_dim
    print_header
    print_footer
  end
end

class MysqlProcess
  def initialize(result, external_pid)
    @id = result[:id]
    @query = result[:query]
    @status = result[:status]
    @time = result[:time]
  end

  attr_accessor :id, :query, :status, :time
end

class Host
  def initialize(hostname, user, pasword)
    @mysql = Mysql2::Client.new(:host => hostname, :username => user, :password => password)
    # rescue connection errors or sumpin
  end

  def slave_status
  end

  def connection_info
  end

  def processlist
    res = []
    processlist = @mysql.query("show full processlist")
    processlist.each(:symbolize_keys => true) do |r|
      res << r
    end

    @processlist = processlist
  end

  def gather
    slave_status
    processlist
    connection_info
  end
end

