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
  c.command do |cmd, config|
    cmd =~ c.regexp
    pid = $1.to_i
    ps = config.find_pid(pid)
    if ps
      puts "%-20s%-6s%-20s%-20s%-20s" % ["status","time","client", "server", "database"]
      puts "%-20s%-6s%-20s%-20s%-20s" % [ps.status, ps.time, ps.client, ps.host.name, ps.db]
      puts ps.sql
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
