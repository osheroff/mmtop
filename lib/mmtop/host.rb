require 'mmtop/qps'

module MMTop
  class Host
    def initialize(hostname, user, password, options)
      m2opts = {}
      m2opts[:host] = hostname
      m2opts[:username] = user
      m2opts[:password] = password
      m2opts[:socket] = options['socket'] if options['socket']
      m2opts[:port] = options['port'] if options['port']
      m2opts[:reconnect] = true
      @mysql = Mysql2::Client.new(m2opts)
      # rescue connection errors or sumpin
      @options = options
      @name = hostname
      @display_name = @name
      @comment = options['comment']
      @last_queries = nil
    end

    attr_accessor :display_name, :name, :comment, :options

    def query(q)
      res = []
      ret = @mysql.query(q)
      return nil unless ret
      ret.each(:symbolize_keys => true) do |r|
        res << r
      end
      res
    end

    def slave_status
      return nil if @options['expect_slave'] == false
      res = query("show slave status")[0]
      return nil if res && res[:Master_User] == 'test'
      res
    end

    def wedge_monitor?
      @options['wedge_monitor']
    end

    def stats
      stats = {}
      queries = query("show global status like 'Questions'")[0][:Value].to_i

      @qps ||= MMTop::QPS.new
      @qps.add_sample(queries, Time.now)
      stats[:qps] = @qps.calc.to_i

      stats
    end

    def processlist
      processlist = query("show full processlist")

      processlist.map { |r| Process.new(r, self) }
    end

    def hostinfo
      HostInfo.new(self, processlist, slave_status, stats)
    end
  end

  class HostInfo
    def initialize(host, processlist, slave_status, stats)
      @host = host
      @processlist = processlist
      @connections = processlist.clone
      @slave_status = slave_status
      @stats = stats
    end

    attr_reader :host, :processlist, :slave_status, :stats

    def connections
      @connections
    end
  end
end
