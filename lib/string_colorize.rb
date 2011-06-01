class String
  CODES = {
    :off       => "\e[0m",
    :bright    => "\e[1m",
    :underline => "\e[4m",
    :blink     => "\e[5m",
    :swap      => "\e[7m",
    :hide      => "\e[8m",

    :black     => "\e[30m",
    :dark_gray => "\e[1;30m",
    :red       => "\e[31m",
    :green     => "\e[32m",
    :yellow    => "\e[33m",
    :blue      => "\e[34m",
    :magenta   => "\e[35m",
    :cyan      => "\e[36m",
    :white     => "\e[37m",
    :default   => "\e[39m",

    :black_background     => "\e[40m",
    :red_background       => "\e[41m",
    :green_background     => "\e[42m",
    :yellow_background    => "\e[43m",
    :blue_background      => "\e[44m",
    :magenta_background   => "\e[45m",
    :cyan_background      => "\e[46m",
    :white_background     => "\e[47m",
    :default_background   => "\e[49m"
  }

  OFF = CODES[:off]

  def colorize(*args)
    color = args.map { |color| CODES[color] if color.is_a?(Symbol) }.join("")
    "#{color}#{self}#{OFF}"
  end
  def colourise(*args); colorize(*args); end

  def red; colorize(:red); end
  def green; colorize(:green); end
  def bold; colorize(:bright); end
  def black; colorize(:black); end
  def white; colorize(:white); end
  def dark_gray; colorize(:dark_gray); end

  def size_uncolorized
    self.gsub(/\e.*?m/, '').size_raw
  end

  alias :size_raw :size
  alias :size :size_uncolorized
end
