require 'tailstrom/counter'
require 'tailstrom/table'
require 'tailstrom/tail_reader'

module Tailstrom
  module Command
    class Stat
      SCHEMA = [
        { :name => 'count', :width => 7 },
        { :name => 'min', :width => 15 },
        { :name => 'max', :width => 15 },
        { :name => 'avg', :width => 15 }
      ]

      def initialize(options)
        @infile = $stdin
        @counter = Counter.new
        @table = Table.new SCHEMA
        @options = options
      end

      def run
        Thread.start do
          reader = TailReader.new @infile, @options
          reader.each_line do |line|
            @counter << line[:value]
          end
        end

        @table.print_header

        loop do
          if @counter
            @table.print_row(
              @counter.count,
              @counter.min,
              @counter.max,
              @counter.avg
            )
          end
          @counter.clear
          sleep @options[:interval]
        end
      rescue Interrupt
        exit 0
      end
    end
  end
end
