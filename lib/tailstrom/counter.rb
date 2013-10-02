module Tailstrom
  class Counter
    def initialize
      clear
    end

    def <<(value)
      @values << value
    end

    def clear
      @values = []
    end

    def avg
      return nil if @values.empty?
      sum / @values.length
    end

    def sum
      @values.inject(0, :+)
    end

    def min
      @values.min
    end

    def max
      @values.max
    end

    def med
      @values[@values.length / 2]
    end

    def count
      @values.count
    end
  end
end
