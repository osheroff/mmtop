MMTop::Command.register do |c|
  c.regexp /h|help|\?/
  c.usage "help"
  c.explain "Display this text"
  c.command do |cmd, config|
    MMTop::Command.commands.sort_by(&:usage).each do |c|
      puts "%-30s %s" % [c.usage, c.explain]
    end
  end
end
