require 'delegate'

class ColorString < Delegator
  OFF = "\e[0m"
  def initialize(string, color)
    @string = string

    if color.is_a?(Array)
      @color_offsets = color
    else
      @color_offsets = [ [0, string.size, color] ]
    end
  end

  attr_reader :color_offsets

  def __getobj__
    @string
  end

  def to_s
    @color_offsets.map { |o|
      o.last + @string[o[0], o[1]] + OFF
    }.join
  end

  def [](range)
    newstr = super
    # I think this code is wrong and bad.
    adjusted_offsets = @color_offsets.map do |o|
      if o[0] > range.last
        nil
      else
        [o[0] - range.first, range.last - range.first, o[2]]
      end
    end.compact
    ColorString.new(newstr, adjusted_offsets)
  end

  def +(other)
    res = @string + other
    if other.is_a?(ColorString)
      adjusted_offsets = other.color_offsets.map do |arr|
        [arr[0] + @string.size, arr[1], arr[2]]
      end
      ColorString.new(res, @color_offsets + adjusted_offsets)
    else
      ColorString.new(res, @color_offsets + [[@string.size, other.size, OFF]])
    end 
  end
end

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
    ColorString.new(self, color)
  end

  def colourise(*args); colorize(*args); end

  def red; colorize(:red); end
  def green; colorize(:green); end
  def bold; colorize(:bright); end
  def black; colorize(:black); end
  def white; colorize(:white); end
  def dark_gray; colorize(:dark_gray); end
end
