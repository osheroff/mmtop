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
end
