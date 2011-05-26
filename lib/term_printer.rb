require 'curses'

module MMTop
  class TermPrinter
    def initialize

    end

    def get_dim
      @y, @x = %x{stty size}.split.collect { |x| x.to_i }
    end

    def corner
      "+"
    end

    def edge
      "-"
    end

    def pipe
      "|"
    end

    def sep
      " | "
    end

    def info_sep
      " | "
    end

    def fill
      "-"
    end

    def print_header
      puts corner + edge * (@x - 2) + corner
    end

    def print_footer
      puts corner + edge * (@x - 2) + corner
    end

    def table_header_columns
      ["hostname        ", "pid  ", "time", "#cx", "slave  ", "delay", Time.now.to_s]
    end

    def column_fill(index)
      "-"  * table_header_columns[index].size
    end

    def sep_fill
      "-"  * sep.size
    end

    def column_value(index, str, fill=" ")
      if str.size < table_header_columns[index].size
        str + (fill * (table_header_columns[index].size - str.size))
      else
        str[0..table_header_columns[index].size - 1]
      end
    end

    def format_slave_status(status)
      if status.nil? || status.keys.empty?
        ""
      else
        if status[:Slave_IO_Running] == 'Yes' && status[:Slave_SQL_Running] == 'Yes'
          "OK"
        elsif status[:Slave_IO_Running] == 'No' && status[:Slave_SQL_Running] == 'No'
          "STOPPED"
        elsif status[:Slave_IO_Running] == 'Yes'
          "!SQL"
        else
          "!IO"
        end
      end
    end

    def format_slave_delay(status)
      return "N/A" unless status
      if status[:Seconds_Behind_Master].nil?
        "N/A"
      else
        format_time(status[:Seconds_Behind_Master])
      end
    end

    def format_time(x)
      case x
        when 0..100
          x.to_s
        when 100..3599
          (x / 60).to_s + "m"
        else
          (x / 3600).to_s + "h"
      end
    end

    def shorten_query(query, size)
      query ? query[0..size-1] : ''
    end

    def clear_screen
      print "\033[H\033[2J"
    end

    def print_process(p)
      return if p.status.nil? || p.status.empty?
      str = pipe + " " + column_value(0, "  " + p.client)
      str += info_sep + column_value(1, p.id ? p.id.to_s : '')
      str += info_sep + column_value(2, format_time(p.time))
      str += info_sep 
      str += shorten_query(p.query, @x - str.size - 1)
      str += " " * (@x - str.size - 1) + pipe
      puts str
    end

    def print_host(info)
      str = pipe + " " + column_value(0, info.host.name + " ", "-")
      str += sep_fill + column_fill(1) + sep_fill + column_fill(2)
      str += info_sep + column_value(3, info.connections.to_s)
      str += info_sep + column_value(4, format_slave_status(info.slave_status))
      str += info_sep + column_value(5, format_slave_delay(info.slave_status))
      str += info_sep
      str += "-" * (@x - str.size - 1)
      str += pipe
      puts str
      info.processlist.each do |p|
        print_process p
      end
    end

    def print_table_header
      str = pipe + " " + table_header_columns.join(sep) + " " + pipe
      puts str + ' ' * (@x - str.size - 1) + pipe
    end

    def print_info(host_infos)
      clear_screen
      get_dim
      print_header
      print_table_header
      print_header
      host_infos.each do |info|
        print_host(info)
      end
      print_footer
    end
  end
end
