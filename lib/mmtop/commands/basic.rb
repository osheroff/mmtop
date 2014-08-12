MMTop::Command.register do |c|
  c.regexp /^h|help|\?/
  c.usage "help"
  c.explain "Display this text"
  c.command do |cmd, config|
    MMTop::Command.commands.sort_by(&:usage).each do |c|
      puts "%-50s %s" % [c.usage, c.explain]
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^q|quit|\?/
  c.usage "quit"
  c.explain "Exit"
  c.command do |cmd, config|
    exit
  end
end


MMTop::Command.register do |c|
  c.regexp /^[x|(?:examine)]\s+(\d+)/
  c.usage "x PID"
  c.explain "Show full query"

  cols = ["status", "time", "client", "src_port", "server", "database"]
  print_ps = lambda do |ps|
    h = {}
    headers = ""
    data = ""
    cols.each { |c|
      val = ps.send(c)
      size = [val.size, c.size].max + 2
      headers += "%-#{size}s" % [c]
      data += "%-#{size}s" % [val]
    }

    puts headers
    puts data
    puts ps.sql
  end

  c.command do |cmd, config|
    cmd =~ c.regexp
    pid = $1.to_i
    ps = config.find_pid(pid)
    if ps
      print_ps.call(ps)
    else
      puts "No such pid #{p}"
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^(?:ex|explain)\s+(\d+)/
  c.usage "explain PID"
  c.explain "Show query plan"
  c.command do |cmd, config|
    cmd =~ c.regexp
    pid = $1.to_i
    ps = config.find_pid(pid)
    if ps
      puts ps.sql
      explain = ps.explain
      pp explain
    else
      puts "No such pid #{p}"
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^(?:l|list)\s+(\S+)/
  c.usage "list HOST"
  c.explain "List hosts and their connections to this server"
  c.command do |cmd, config|
    cmd =~ c.regexp
    host = $1

    server = config.find_server(host)
    if server
      cxs = {}
      server.connections.each do |cx|
        client = MMTop::ReverseLookup.lookup(cx.client)
        cxs[client] ||= 0
        cxs[client] += 1
      end

      cxs.sort_by { |k, v| [-v, k] }.each { |k, v|
        puts "#{k}: #{v}"
      }
    else
      puts "No such host: #{server}"
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^sleep\s+([\d\.]+)/
  c.usage "sleep TIME"
  c.explain "Set mmtop sleep time"
  c.command do |cmd, config|
    cmd =~ c.regexp
    sleep = $1.to_f
    if sleep == 0.0
      puts "sleep must be over 0."
    end
    config.options['sleep'] = sleep
  end
end

MMTop::Command.register do |c|
  c.regexp /^shell (.*)/
  c.usage   "shell HOST|PID"
  c.explain "open up a mysql command-line client on HOST or on the database that PID is on"
  c.command do |cmd, config|
    cmd =~ c.regexp
    match = $1

    if match =~ /^\d+$/
      ps = config.find_pid(match.to_i)
      if !ps
        break puts "No such PID: #{match}"
      end

      host = ps.host
    else
      server = config.find_server(match)
      if !server
        break puts "No such host: #{server}"
      end
      host = server.host
    end
    opt = host.options
    system("mysql --user='#{opt['user']}' --host='#{opt['host']}' --password='#{opt['password']}'")
  end
end
