require 'tailstrom/counter'

module Tailstrom
  class CounterCollection
    def initialize
      clear
    end

    def clear
      @counters = Hash.new {|h, k| h[k] = Counter.new }
    end

    def [](key)
      @counters[key]
    end

    def empty?
      @counters.empty?
    end

    def each(&block)
      @counters.each &block
    end

    def to_a
      @counters.to_a
    end

    def size
      @counters.size
    end
  end
end
