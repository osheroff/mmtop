module MMTop
  Filter.add_filter('strip_empty') do |queries|
    queries.reject! { |q| q.sql.nil? || q.sql.strip.empty? }
  end

  Filter.add_filter('trim_whitespace') do |queries|
    queries.each { |q| q.sql.gsub!(/\s+/, ' ') }
  end

  Filter.add_filter('sort_by_time') do |queries|
    queries.sort! { |a, b| b.time <=> a.time }
  end

  WEDGE_THRESHOLD=10
  Filter.add_filter('wedge_monitor') do |queries, hostinfo, config|
    if hostinfo.host.wedge_monitor? 
      if queries.size > WEDGE_THRESHOLD
        wedge_filename = config.options['wedge_log'] || 'mmtop_wedge_log'
        File.open(wedge_filename, "a+") do |f|
          puts("Wedge detected on #{hostinfo.host.name}.  Dumping queries")
          f.puts("======================== #{Time.now} =========================")
          queries.each do |q|
            f.puts(q.sql)
          end
          sleep(5)
        end
      end
    end
  end
end
