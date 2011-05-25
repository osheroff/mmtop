module MMTop
  class Host
    def initialize(hostname, user, password, options)
      m2opts = {}
      m2opts[:host] = hostname
      m2opts[:username] = user
      m2opts[:password] = password
      m2opts[:socket] = options['socket'] if options['socket']
      m2opts[:port] = options['port'] if options['port']
      @mysql = Mysql2::Client.new(m2opts)
      # rescue connection errors or sumpin
      @options = options
      @name = hostname
    end

    attr_accessor :name

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
      query("show slave status")[0]
    end

    def processlist
      processlist = query("show full processlist")

      processlist.map { |r| Process.new(r, self) }
    end

    def hostinfo
      HostInfo.new(self, processlist, slave_status)
    end
  end

  class HostInfo
    def initialize(host, processlist, slave_status)
      @host = host
      @processlist = processlist
      @slave_status = slave_status
    end

    attr_reader :host, :processlist, :slave_status

    def connections
      processlist.size
    end
  end
end
