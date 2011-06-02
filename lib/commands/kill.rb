module MMTop
  class Command
    def self.kill_prompt(queries)
      if queries.empty?
        puts "No queries matched."
        return
      end
  
      puts "killing: "
      queries.each_with_index do |q, i|
        puts "#{i}: #{q.host.name}\t\t#{q.sql[0..80]}"
      end

      print "Please confirm (y|n)> "
      if $stdin.readline != "y\n"
        puts "no, ok."
      else
        queries.each(&:kill!)
        puts "killed."
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


