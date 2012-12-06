module MMTop
  class Command
    def self.parse_kill_selection(str)
      strs = str.split(/\s*,\s*/).map(&:strip)
      strs.map { |s|
        if not s =~ /^[0-9-\*]+$/
          $stdout.puts("Invalid query selection, try again")
          return nil
        else
          if s.include?("-")
            a = s.split("-").map(&:strip)
            ((a[0].to_i)..(a[1].to_i)).to_a
          elsif s == "*"
            s
          else
            s.to_i
          end
        end
      }.flatten
    end

    def self.kill_prompt(queries)
      if queries.empty?
        puts "No queries matched."
        return
      end

      puts "killing: "
      queries.each_with_index do |q, i|
        puts "#{i}: #{q.host.name}\t\t#{q.sql[0..80]}"
      end

      print "What shall I kill? (ex: 1-4,5,9|*)> "

      line = $stdin.readline
      if line == "\n"
        puts "nothing, ok."
      else
        indexes = parse_kill_selection(line)
        indexes.each { |i|
          if i == "*"
            queries.each(&:kill!)
          elsif queries[i]
            queries[i].kill!
          else
            puts "No such query: #{i}"
          end
        }
      end
    end
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
  c.regexp %r{^k(:?ill)?\s+l(:?ong)?\s+(\d+)\s*(\w*)}
  c.usage "kill long TIME [SERVER]"
  c.explain "Kill any queries over TIME seconds on optional server"
  c.command do |cmd, config|
    cmd =~ c.regexp
    time = $3.to_i
    server = $4.strip
    list = config.all_processes.select { |p|
      p.time > time && p.sql =~ /select/i && (server.nil? || server.size == 0 || (server == p.host.name))
    }
    MMTop::Command.kill_prompt(list)
  end
end


MMTop::Command.register do |c|
  c.regexp %r{^k(ill)?\s+(/.*/\w*)}
  c.usage "kill /REGEXP/"
  c.explain "Kill a number of queries by REGEXP"
  c.command do |cmd, config|
    cmd =~ c.regexp
    r = eval($2)
    if !r.is_a?(Regexp)
      puts "Invalid regexp \"#{$1}\""
    else
      MMTop::Command.kill_prompt(config.all_processes.select { |p| r.match(p.sql) })
    end
  end
end


