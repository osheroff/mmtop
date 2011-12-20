module MMTop
  class Command
    def matches?(cmd)
      @regexp.match(cmd)
    end

    def run(cmd, config)
      cmd =~ @regexp
      @command.call(cmd, config)
    end

    def regexp(r = nil)
      @regexp = r if r
      @regexp
    end

    def usage(u = nil)
      @usage = u if u
      @usage
    end

    def explain(e = nil)
      @explain = e if e
      @explain
    end

    def command(&block)
      @command = block.to_proc
    end

    class <<self
      def register
        @commands ||= []
        c = self.new
        yield c
        @commands << c
      end

      attr_accessor :commands
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "commands/*")).each { |f| require f }

