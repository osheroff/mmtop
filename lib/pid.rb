module MMTop
  class PID
    def self.get
      @id += 1
    end
    def self.reset
      @id = 0
    end
  end
end

