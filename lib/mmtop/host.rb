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
      @options = options
      @name = hostname
      @display_name = @name
      @comment = options['comment']
      @last_queries = nil
      puts options
      @hide_if_empty = options['hide_if_empty']

      initialize_mysql2_cx(m2opts)
    end

    def initialize_mysql2_cx(m2opts)
      begin
        @mysql = Mysql2::Client.new(m2opts)
      rescue Mysql2::Error => e
        if e.error_number == 2003
          mark_dead!
        else
          $stdout.puts("Got Error Number #{e.error_number} (#{e.inspect}) trying to connect to #{@name}")
          mark_dead!
          sleep(1)
        end
      end
    end

    attr_accessor :display_name, :name, :comment, :options, :ip

    def hide_if_empty?
      !!@hide_if_empty
    end

    def query(q)
      return [] if dead?

      res = []
      begin
        ret = @mysql.query(q)
      rescue Mysql2::Error => e
        if [2007, 2013, 2003].include?(e.error_number)
          mark_dead!
          return []
        else
          puts "Got error number " + e.error_number.to_s
          raise e
        end
      end

      return nil unless ret
      ret.each(:symbolize_keys => true) do |r|
        res << r
      end
      res
    end

    def mark_dead!
      @dead = true
    end

    def dead?
      @dead
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
      row = query("show global status like 'Questions'")
      return {} if row.empty?

      queries = row.first[:Value].to_i

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
      @connections = processlist.clone
      @slave_status = slave_status
      @stats = stats
      @processlist = processlist
    end

    def processlist
      @processlist.select { |p| !p.status.nil? && !p.status.empty? }
    end
    attr_reader :host, :slave_status, :stats, :connections
  end
end
