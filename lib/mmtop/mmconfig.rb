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
        h = {'host' => h} if h.is_a?(String)

        h['user'] ||= (user || config['user'])
        h['password'] ||= (pass || config['password'])
        h['wedge_monitor'] ||= config['wedge_monitor']

        Host.new(h['host'], h['user'], h['password'], h)
      end.compact.uniq { |h| h.name } 

      @filters = MMTop::Filter.default_filters
      config['sleep'] ||= 5
      @options = config
    end

    attr_accessor :hosts
    attr_accessor :info
    attr_accessor :filters
    attr_accessor :options

    def find_pid(pid)
      ret = info.map { |i|
        i.processlist.detect { |p|
          p.id == pid
        }
      }.flatten.compact

      ret[0]
    end

    def find_server(name)
      @info.detect { |i| i.host.name.downcase == name }
    end

    def run_filters
      @info.each do |i|
        @filters.each do |f|
          f.run(i.processlist, i, self)
        end
      end
    end

    def all_processes
      @info.map(&:processlist).flatten
    end

    def get_info
      @info = hosts.map { |h| h.hostinfo }
      run_filters
    end
  end
end
