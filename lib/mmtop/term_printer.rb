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
      puts corner + edge * (@x - 2) + corner
    end

    def table_header_columns
      @header_columns ||= ["hostname        ", "pid  ", "time", "#cx", "slave  ", "delay", "qps   ", "shards           ", Time.now.to_s]
    end

    def column_fill(index)
      fill * table_header_columns[index].size
    end

    def sep_fill
      fill * sep.size
    end

    def column_value_with_fill(index, str, fill, align)
      fill_str = fill * (table_header_columns[index].size - str.size)
      if align == :left
        str + fill_str
      else
        fill_str + str
      end
    end

    def column_value(index, str, fill=" ", align=:left)
      if str.size < table_header_columns[index].size
        column_value_with_fill(index, str, fill, align)
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
      return if p.status.nil? || p.status.empty?
      str = pipe + " " + column_value(0, p.client, ' ', :right)
      str += info_sep + column_value(1, p.id ? p.id.to_s : '')
      str += info_sep + column_value(2, format_time(p.time))
      str += info_sep
      str += format_process(p, @x - str.size - 1)
      str += " " * (@x - str.size - 1) + pipe
      puts str
    end

    def format_shards(shards)

      shards.sort! do |a,b| a.id <=> b.id end

      group_first = nil
      group_last = nil
      shards_str = []
      shards.each do |this_shard|

        if ! group_first

          # start first group
          group_first = this_shard
          group_last = this_shard

        else

          if group_last.env == this_shard.env and group_last.id + 1 == this_shard.id
            # continue group
            group_last = this_shard
          else
            # end prvious group
            if group_first == group_last
              shards_str.push( group_first.id.to_s + '_' + group_first.env )
            else
              shards_str.push( group_first.id.to_s + '-' + group_last.id.to_s + '_' + group_last.env )
            end

            # start new group
            group_first = this_shard
            gorup_last = this_shard
          end

        end
      end

      # end last group
      if group_first 
        if group_first == group_last
          shards_str.push( group_first.id.to_s + '_' + group_first.env )
        else
          shards_str.push( group_first.id.to_s + '-' + group_last.id.to_s + '_' + group_last.env )
        end
      end

      return shards_str * ','
    end

    def print_host(info)
      display_name = info.host.display_name
      display_name = (display_name + "!").red if info.host.dead?
      str = pipe + " " + column_value(0, display_name + " " + (info.host.comment || ""), "-".dark_gray)
      str += sep_fill + column_fill(1) + sep_fill + column_fill(2)
      str += info_sep + column_value(3, info.connections.size.to_s)
      str += info_sep + column_value(4, format_slave_status(info.slave_status))
      str += info_sep + column_value(5, format_slave_delay(info.slave_status))
      str += info_sep + column_value(6, info.stats[:qps].to_s)
      str += info_sep + column_value(7, format_shards(info.shards))
      #str += info_sep + column_value(7, info.host.comment || '')
      str += info_sep
      str += "-".dark_gray * (@x - str.size - 1)
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
