require 'yaml'

module MMTop
  class Config
    def initialize(cmdline)
      config_file = cmdline["-c"] || File.join(ENV["HOME"], ".mmtop_config")
      raise "No file found: #{config_file}" unless File.exist?(config_file)
      config = YAML.load_file(config_file)

      if config['hosts'].nil? || config['hosts'].empty?
        raise "Please configure the 'hosts' section of mmtop_config"
      end

      cmdline_user = cmdline['-u']
      cmdline_pass = cmdline['-p']
      @hosts = config['hosts'].map do |h|
        h = {'host' => h} if h.is_a?(String)

        defaults = {'user' => (cmdline_user || config['user']), 'password' => (cmdline_pass || config['password'])}
        h = defaults.merge(h)

        Host.new(h['host'], h['user'], h['password'], h)
      end.compact.uniq { |h| h.name }

      config['sleep'] ||= 5

      if config['plugin_dir']
        Dir.glob("#{config['plugin_dir']}/**/*.rb").each { |f| require(f) }
      end

      @filters = MMTop::Filter.default_filters

      @options = config

      @quick = cmdline["-q"]
    end

    attr_accessor :hosts
    attr_accessor :info
    attr_accessor :filters
    attr_accessor :options
    attr_accessor :quick

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
