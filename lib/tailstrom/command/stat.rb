require 'tailstrom/counter_collection'
require 'tailstrom/table'
require 'tailstrom/tail_reader'

module Tailstrom
  module Command
    class Stat
      def initialize(options)
        @infile = options[:static_infile] || $stdin
        @counters = CounterCollection.new
        @options = { :async => !options[:static_infile] }.merge options
        @table = Table.new schema
      end

      def schema
        s = [
          { :name => 'count', :width => 7 },
          { :name => 'min', :width => 10 },
          { :name => 'max', :width => 10 },
          { :name => 'avg', :width => 10 },
          { :name => 'key', :width => 10, :align => :left }
        ]
        if @options[:async]
          [ { :name => 'time', :width => 8 } ] + s
        else
          s
        end
      end

      def run
        reader = TailReader.new @infile, @options
        reader.each_line do |line|
          @counters[line[:key]] << line[:value]
        end

        height = `put lines`.to_i - 4 rescue 10
        @i = 0
        begin
          sleep @options[:interval]

          if @i % height == 0
            @table.print_header
          end

          @counters.to_a.sort_by {|key, c|
            c.sum
          }.reverse_each do |key, c|
            key = (key == :nil ? nil : key)
            if @options[:async]
              time = Time.now.strftime("%H:%M:%S")
              @table.print_row time, c.count, c.min, c.max, c.avg, key
            else
              @table.print_row c.count, c.min, c.max, c.avg, key
            end
          end

          if @counters.size > 1
            @table.puts
          end

          @counters.clear
          @i = @i + 1
        end while !reader.eof?
      rescue Interrupt
        exit 0
      end
    end
  end
end
