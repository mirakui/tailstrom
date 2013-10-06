module Tailstrom
  class Counter
    def initialize
      clear
    end

    def <<(value)
      purge_cache
      @values << value
    end

    def clear
      @values = []
      purge_cache
    end

    def purge_cache
      @cache = {}
    end

    def avg
      return nil if @values.empty?
      sum / @values.length
    end

    def sum
      @cache[:sum] ||= @values.inject(0, :+)
    end

    def min
      @cache[:min] ||= @values.min
    end

    def max
      @cache[:max] ||= @values.max
    end

    def med
      @values[@values.length / 2]
    end

    def count
      @cache[:count] ||= @values.count
    end
  end
end
