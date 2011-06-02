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
    end

    attr_accessor :query, :status, :time, :client, :host, :db

    def id
      @id ||= MMTop::PID.get
    end

    def kill!
      @host.query("KILL #{@real_id}")
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
