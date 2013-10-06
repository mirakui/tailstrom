require 'tailstrom/counter_collection'
require 'tailstrom/table'
require 'tailstrom/tail_reader'

module Tailstrom
  module Command
    class Stat
      SCHEMA = [
        { :name => 'time', :width => 8 },
        { :name => 'count', :width => 7 },
        { :name => 'min', :width => 10 },
        { :name => 'max', :width => 10 },
        { :name => 'avg', :width => 10 },
        { :name => 'key', :width => 10, :align => :left }
      ]

      def initialize(options)
        @infile = $stdin
        @counters = CounterCollection.new
        @table = Table.new SCHEMA
        @options = options
      end

      def run
        Thread.start do
          reader = TailReader.new @infile, @options
          reader.each_line do |line|
            key = line[:key] || :all
            @counters[key] << line[:value]
          end
        end

        height = `put lines`.to_i - 4 rescue 10
        @i = 0
        loop do
          sleep @options[:interval]

          @table.print_header if (@i = (@i + 1) % height) == 1

          @counters.each do |key, c|
            key = (key == :all ? nil : key)
            time = Time.now.strftime("%H:%M:%S")
            @table.print_row time, c.count, c.min, c.max, c.avg, key
          end
          @counters.clear
        end
      rescue Interrupt
        exit 0
      end
    end
  end
end
