module MMTop
  class Filter
    class << self
      attr_accessor :filters

      def add_filter(name, default=true, &block)
        @filters ||= []
        @filters.push self.new(name, default, &block)
      end

      def default_filters
        @filters.select(&:default)
      end
    end

    def initialize(name, default, &block)
      @name = name
      @default = default
      @block = block.to_proc
    end

    def run(query_list)
      @block.call(query_list)
    end
    attr_accessor :name, :default
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "filters/*")).each { |f| require f }
