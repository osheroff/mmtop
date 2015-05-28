module MMTop
  class PID
    @iteration = 0

    def self.pid_array
      @pid_array ||= []
    end

    def self.pid_hash
      @pid_hash ||= {}
    end

    def self.get(host, real_id)
      key = [host, real_id]

      pid = pid_hash[key]
      if !pid
        pid = pid_array.index(nil) || pid_array.size
      end 

      pid_hash[key] = pid
      pid_array[pid] = @iteration
      pid
    end

    def self.reset
      to_delete = pid_hash.map do |k, v|
        # recycle pid after 2 loops
        if pid_array[v] && pid_array[v] < @iteration - 1
          k
        end
      end.compact

      to_delete.each do |k|
        idx = pid_hash.delete(k)
        pid_array[idx] = nil
      end

      @iteration += 1
    end
  end
end

