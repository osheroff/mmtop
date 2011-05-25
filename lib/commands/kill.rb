MMTop::Command.register do |c|
  c.regexp /k(:?ill)?(\s+\d+)/
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
