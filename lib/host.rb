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
      query("show slave status")[0]
    end

    def wedge_monitor?
      @options['wedge_monitor']
    end

    def stats
      stats = {}
      queries = query("show global status like 'Questions'")[0][:Value].to_i

      if @last_queries
        elapsed = Time.now.to_i - @last_queries[:time]
        if elapsed > 0 
          qps = (queries - @last_queries[:count]) / elapsed
        else 
          qps = queries - @last_queries[:count]
        end
        stats[:qps] = qps
      end
      @last_queries = {}
      @last_queries[:count] = queries
      @last_queries[:time] = Time.now.to_i
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
