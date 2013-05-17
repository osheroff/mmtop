#!/usr/bin/env ruby

require "mysql_isolated_server"

threads = []
threads << Thread.new do
  $mysql_master = MysqlIsolatedServer.new(allow_output: false)
  $mysql_master.boot!

  puts "mysql master booted on port #{$mysql_master.port} -- access with mysql -uroot -h127.0.0.1 --port=#{$mysql_master.port} mysql"
end

threads << Thread.new do
  $mysql_slave = MysqlIsolatedServer.new
  $mysql_slave.boot!

  puts "mysql slave booted on port #{$mysql_slave.port} -- access with mysql -uroot -h127.0.0.1 --port=#{$mysql_slave.port} mysql"
end

threads << Thread.new do
  $mysql_slave_2 = MysqlIsolatedServer.new
  $mysql_slave_2.boot!

  puts "mysql chained slave booted on port #{$mysql_slave_2.port} -- access with mysql -uroot -h127.0.0.1 --port=#{$mysql_slave_2.port} mysql"
end

threads.each(&:join)

$mysql_master.connection.query("CHANGE MASTER TO master_host='127.0.0.1', master_user='root', master_password=''")
$mysql_slave.make_slave_of($mysql_master)
$mysql_slave_2.make_slave_of($mysql_slave)

$mysql_slave.set_rw(false)
sleep if __FILE__ == $0
