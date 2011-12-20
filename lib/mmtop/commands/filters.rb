MMTop::Command.register do |c|
  c.regexp /^filter\s+list/
  c.usage "filter list"
  c.explain "Show active filters"
  c.command do |cmd, config|
    config.filters.each_with_index do |f, i|
      puts "#{i}: #{f.name}"
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^filter\s+available/
  c.usage "filter available"
  c.explain "Show available filters"
  c.command do |cmd, config|
    MMTop::Filter.filters.each do |o|
      puts "#{o.name}"
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^filter\s+add/
  c.usage "filter add [{ BLOCK } | NAME] [POSITION]"
  c.explain "Add a new filter into the chain.  For the { BLOCK } form, the block has access to the \'query\' variable.  see docs for more info."
  c.command do |cmd, config|
    cmd =~ /filter\s+add(.*)/
  
    filter = nil
    position = nil
    rest = $1
    if rest =~ /\{(.*)\}\s*(\d*)/
      eval_bits = $1.strip
      position = $2
      begin 
        filter = MMTop::Filter.from_string(eval_bits) 
      #rescue Exception => e
      #  puts "error evaluating filter block: #{e}"
      end
    else
      name, position = rest.strip.split(/\s+/)
      filter = MMTop::Filter.filters.detect { |f| f.name == name } 
      if filter.nil? 
        puts "No such filter: '#{name}'"
      end
    end

    if filter
      if position && !position.empty?
        config.filters.insert(position.to_i, filter)
      else
        config.filters.push(filter)
      end
    end
  end
end

MMTop::Command.register do |c|
  c.regexp /^filter\s+rm\s+(\d+)/
  c.usage "filter rm [POSITION]"
  c.explain "Remove the filter at [POSITION]"
  c.command do |cmd, config|
    cmd =~ c.regexp
    pos = $1.to_i
    if !config.filters[pos]
      puts "No filter at #{pos}"
    else
      config.filters.slice!(pos)
    end
  end
end

