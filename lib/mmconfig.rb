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
    end

    attr_accessor :hosts
    attr_accessor :info

    def find_pid(pid)
      ret = info.map { |i|
        i.processlist.detect { |p|
          p.id == pid
        }
      }.flatten.compact

      ret[0]
    end

    def get_info
      @info = hosts.map { |h| h.hostinfo }
    end
  end
end
