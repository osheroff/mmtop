module MMTop
  class QPS
    DEFAULT_WINDOW = 20

    QUERIES = 0
    TIME = 1
    def self.window
      @window || DEFAULT_WINDOW
    end

    def self.window=(window)
      @window = window
    end

    def window
      self.class.window
    end

    def add_sample(queries, time)
      samples.push [queries, time]
      clean_samples
    end

    def calc
      clean_samples
      return '...' if samples.size == 1

      queries = samples.last[QUERIES] - samples.first[QUERIES]
      time = samples.last[TIME].to_i - samples.first[TIME].to_i

      queries / time
    end

  private

    def clean_samples
      while samples.first[TIME].to_i < (Time.now.to_i - window)
        samples.shift
      end
    end

    def samples
      @samples ||= []
    end
  end
end
