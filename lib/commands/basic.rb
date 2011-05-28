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
  c.regexp /^k(:?ill)?(\s+\d+)/
  c.usage "kill [PID] [..PID]"
  c.explain "Kill a number of queries by PID"
  c.command do |cmd, config|
    pids = []
    procs = []
    cmd.gsub(/\s+\d+/) { |p| pids << p.to_i }

    pids.each { |p|
      ps = config.find_pid(p)
      if ps.nil?
        puts "No such pid: #{p}"
        next
      end
      procs << ps
    }
    procs.each { |ps| ps.kill! }
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
      puts "%-20s%-6s%-20s%-20s" % ["status","time","client", "server"]
      puts "%-20s%-6s%-20s%-20s" % [ps.status, ps.time, ps.client, ps.host.name]
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
