require 'timeout'

module MMTop
  class TermInput
    def raw(bool)
      if bool
        %x{stty -echo raw}
      else
        %x{stty echo -raw}
      end
    end

    def initialize(sleep)
      @sleep = sleep
    end

    def find_command(cmd)
      MMTop::Command.commands.detect { |c| c.matches?(cmd) }
    end

    def control_mode(config)
      raw(false)
      while true
        print "> "
        $stdout.flush
        cmdline = $stdin.readline
        return if cmdline == "\n"

        c = find_command(cmdline)
        if c.nil?
          c = find_command("help")
        end
        c.run(cmdline, config)
      end
    end

    def control(config)
      raw(true)
      char = nil
      begin
        Timeout::timeout(@sleep) do
          char = $stdin.read(1)
        end
      rescue Timeout::Error
        return
      end

      case char
        when "\n"
          return
        when "p"
          control_mode(config)
        when "q"
          exit(0)
      end
      ensure
        raw(false)
    end
  end
end
