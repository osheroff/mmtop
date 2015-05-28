module MMTop
  class Process
    def initialize(result, host)
      @real_id = result[:Id]
      @query = result[:Info]
      @status = result[:State]
      @time = result[:Time]
      @client, @client_port = result[:Host] && result[:Host].split(":")
      @client ||= "(slave)"
      @client_port ||= ""
      @db = result[:db]
      @host = host
      clean_sql!
    end

    attr_accessor :query, :status, :time, :client, :host, :db
    alias :database :db

    def id
      @id ||= MMTop::PID.get(@host, @real_id)
    end

    def kill!
      begin
        @host.query("KILL #{@real_id}")
      rescue Mysql2::Error => e
        puts e
      end
    end

    def clean_sql!
      if @query && !@query.valid_encoding?
        @query = @query.chars.select { |c| c.valid_encoding? }.join
      end
    end

    def server
      @host.name
    end

    def src_port
      @client_port
    end

    def sql
      @query
    end

    def explain
      @host.query("use #{db}")
      @host.query("explain #{sql}")
    end
  end
end
