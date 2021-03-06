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
        [
          ({ :name => 'time', :width => 8 } if @options[:async]),
          { :name => 'count', :width => 7 },
          { :name => 'min', :width => 10 },
          { :name => 'max', :width => 10 },
          { :name => 'avg', :width => 10 },
          { :name => 'key', :width => 10, :align => :left }
        ].compact
      end

      def run
        reader = TailReader.new @infile, @options
        reader.each_line do |line|
          @counters[line[:key]] << line[:value]
        end

        height = terminal_height
        printed_lines_sum = printed_lines = 0
        begin
          sleep @options[:interval]

          if printed_lines > 0 && (@multiline ||= @counters.size > 1)
            @table.puts
            printed_lines += 1
          end
          printed_lines = 0

          if (printed_lines_sum %= height) == 0
            @table.print_header
          end

          if @counters.size == 0
            @counters[:nil].count
          end

          printed_lines = print_counters
          printed_lines_sum += printed_lines

          @counters.clear
        end until reader.eof?
      rescue Interrupt
        exit 0
      end

      private
        def terminal_height
          system 'which tput 2>&1 >/dev/null'
          if $? == 0
            `tput lines`.to_i - 4
          else
            10
          end
        end

        def print_counters
          printed_lines = 0
          sorted_counters.each do |key, c|
            key = (key == :nil ? nil : key)
            next unless out_filter(key, c)
            if @options[:async]
              time = Time.now.strftime("%H:%M:%S")
              @table.print_row time, c.count, c.min, c.max, c.avg, key
            else
              @table.print_row c.count, c.min, c.max, c.avg, key
            end
            printed_lines += 1
          end
          printed_lines
        end

        def sorted_counters
          counters = @counters.to_a
          if sort = @options[:sort]
            counters = counters.sort_by do |key, c|
              sum, avg, min, max, count =
                c.sum, c.avg, c.min, c.max, c.count
              eval sort
            end
          else
            counters = counters.sort_by do |key, c|
              c.sum
            end
          end
          @options[:order] == :asc ? counters : counters.reverse
        end

        def out_filter(key, counter)
          if filter = @options[:out_filter]
            sum, avg, min, max, count =
              counter.sum, counter.avg, counter.min, counter.max, counter.count
            eval filter
          else
            true
          end
        end
    end
  end
end
