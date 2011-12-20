require 'timeout'
require 'readline' 

module MMTop
  class TermInput
    def raw(bool)
      if bool
        %x{stty -echo raw}
      else
        %x{stty echo -raw}
      end
    end

    def initialize()
    end

    def find_command(cmd)
      MMTop::Command.commands.detect { |c| c.matches?(cmd) }
    end

    def control_mode(config)
      raw(false)
      while true
        cmdline = Readline::readline('> ')
        exit if cmdline.nil?
        Readline::HISTORY.push(cmdline) 
        return if cmdline.empty?
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
        Timeout::timeout(config.options['sleep']) do
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
