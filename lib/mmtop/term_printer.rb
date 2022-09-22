require 'mmtop/string_colorize'

module MMTop
  class TermPrinter
    def initialize
      $stdout.sync = true
    end

    def reset!
      @header_columns = nil
      get_dim
    end

    def get_dim
      @y, @x = %x{stty size}.split.collect { |x| x.to_i }
    end

    def corner
      "+".dark_gray
    end

    def edge
      "-".dark_gray
    end

    def pipe
      "|".dark_gray
    end

    def sep
      " | ".dark_gray
    end

    def info_sep
      " | ".dark_gray
    end

    def fill
      "-".dark_gray
    end

    def print_header
      puts corner + edge * (@x - 2) + corner
    end

    def print_footer
      footer_banner = (" mmtop version #{MMTop::VERSION} ".dark_gray) + "...".dark_gray + " press \"p\" to pause ".dark_gray
      left_border_size = (@x - 2 - footer_banner.size) / 2 
      right_border_size = @x - 2 - footer_banner.size - left_border_size
      puts corner + (edge * left_border_size) + footer_banner + (edge * right_border_size) + corner
    end

    def table_header_columns
      @header_columns ||= ["hostname        ", "pid  ", "time", "#cx", "slave  ", "delay", "qps   ", "comment " + info_sep + Time.now.to_s]
    end

    def column_fill(index)
      fill * table_header_columns[index].size
    end

    def sep_fill
      fill * sep.size
    end

    def column_value_with_fill(index, max_size, str, fill, align)
      fill_str = fill * (max_size - str.size)
      if align == :left
        str + fill_str
      else
        fill_str + str
      end
    end

    def column_value(indexes, str, fill=" ", align=:left)
      indexes = Array(indexes)
      max_size = indexes.inject(0) { |s, idx| s + table_header_columns[idx].size }
      max_size += sep_fill.size * (indexes.size - 1)
	
      if str.size < max_size
        column_value_with_fill(indexes.first, max_size, str, fill, align)
      else
        str[0..max_size - 1]
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
      return "" unless status
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

    def format_process(process, sz)
      query = process.sql ? process.sql[0..sz-2] : ''
      case process.time
        when 0..2
          query
        when 2..10
          query.white.bold
        else
          query.red
      end
    end

    def clear_screen
      print "\033[H\033[2J"
    end

    def print_process(p)
      str = pipe + " " + column_value(0, p.client, ' ', :right)
      str += info_sep + column_value(1, p.id ? p.id.to_s : '')
      str += info_sep + column_value(2, format_time(p.time))
      str += info_sep
      str += format_process(p, @x - str.size - 1)
      str += " " * (@x - str.size - 1) + pipe
      puts str
    end

    def print_host(info)
      return if (info.processlist.empty? && info.host.hide_if_empty?) || info.host.hide

      display_name = info.host.display_name
      if info.host.dead?
        display_name = ("!" + display_name).red 
        info.host.comment = info.host.error_message
      end

      str = pipe + " " + column_value([0, 1, 2], display_name + " ", "-".dark_gray)
    
      str += info_sep + column_value(3, info.connections.size.to_s)
      str += info_sep + column_value(4, format_slave_status(info.slave_status))
      str += info_sep + column_value(5, format_slave_delay(info.slave_status))
      str += info_sep + column_value(6, info.stats[:qps].to_s)
      str += info_sep + column_value(7, info.host.comment || '')
      str += info_sep

      fill_count = (@x - str.size - 1)
      str += "-".dark_gray * fill_count if fill_count > 0
      str += pipe
      puts str
      info.processlist.each do |p|
        print_process p
      end
    end

    def print_table_header
      if table_header_columns.join(sep).size + 4 > @x
        table_header_columns[-1] = ''
      end

      str = pipe + " " + table_header_columns.join(sep)
      fill_len = (@x - str.size) - 1

      print str
      print ' ' * fill_len if fill_len > 0
      puts pipe
    end

    def print_info(host_infos)
      #max_comment_size = host_infos.map { |i| (i.host.comment && i.host.comment.size).to_i }.max
      #comment_index = 7
      #table_header_columns[comment_index] += (' ' * (max_comment_size - table_header_columns[comment_index].size)) if max_comment_size > table_header_columns[comment_index].size

      clear_screen
      reset!
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
