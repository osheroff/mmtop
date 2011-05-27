module MMTop
  class Process
    def initialize(result, host)
      @real_id = result[:Id]
      @id = MMTop::PID.get
      @query = result[:Info]
      @status = result[:State]
      @time = result[:Time]
      @client, @client_port = result[:Host] && result[:Host].split(":") 
      @client ||= "(slave)"
      @client_port ||= ""
      @db = result[:db]
      @host = host
    end

    attr_accessor :id, :query, :status, :time, :client, :host, :db

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
