require 'tailstrom/counter'

module Tailstrom
  class CounterCollection
    def initialize
      @counters = Hash.new {|h, k| h[k] = Counter.new }
    end

    def clear
      @counters.values.each(&:clear)
    end

    def [](key)
      @counters[key]
    end

    def empty?
      @counters.empty?
    end

    def each(&block)
      @counters.each(&block)
    end
  end
end
