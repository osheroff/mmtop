module MMTop
  class Config
    def initialize(cmdline)
      config_file = cmdline["-c"] || File.join(ENV["HOME"], ".mmtop_config")
      raise "No file found: #{config_file}" unless File.exist?(config_file)
      config = YAML.load_file(config_file)

      if config['hosts'].nil? || config['hosts'].empty?
        raise "Please configure the 'hosts' section of mmtop_config"
      end

      user = cmdline['-u']
      pass = cmdline['-p']
      @hosts = config['hosts'].map do |h|
        h['user'] ||= (user || config['user'])
        h['password'] ||= (pass || config['password'])
        Host.new(h['host'], h['user'], h['password'], h)
      end

      @filters = MMTop::Filter.default_filters
    end

    attr_accessor :hosts
    attr_accessor :info
    attr_accessor :filters

    def find_pid(pid)
      ret = info.map { |i|
        i.processlist.detect { |p|
          p.id == pid
        }
      }.flatten.compact

      ret[0]
    end

    def run_filters
      @info.each do |i|
        @filters.each do |f|
          f.run(i.processlist)
        end
      end
    end

    def get_info
      @info = hosts.map { |h| h.hostinfo }
      run_filters
    end
  end
end
