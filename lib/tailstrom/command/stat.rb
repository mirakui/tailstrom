require 'optparse'
require 'tailstrom/counter'
require 'tailstrom/table'
require 'thread'

module Tailstrom
  module Command
    class Stat
      SCHEMA = [
        { :name => 'count', :width => 7 },
        { :name => 'min', :width => 15 },
        { :name => 'max', :width => 15 },
        { :name => 'avg', :width => 15 }
      ]

      def initialize(argv)
        @infile = $stdin
        @counter = Counter.new
        @table = Table.new SCHEMA
        parse_option argv
      end

      def run
        Thread.start {
          @infile.each_line do |line|
            line = line.chomp
            parse_line line
          end
        }

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

      def parse_line(line)
        columns = line.split @options[:delimiter]
        value = @options[:field] ? columns[@options[:field]] : line
        value = value =~ /\./ ? value.to_f : value.to_i
        @counter << value
      end

      def parse_option(argv)
        @options = {
          :delimiter => "\t",
          :interval => 1
        }
        opt = OptionParser.new(argv)
        opt.on('-f [field]', Integer) {|v| @options[:field] = v - 1 }
        opt.on('-d [delimiter]', String) {|v| @options[:delimiter] = v }
        opt.on('-i [interval]', Integer) {|v| @options[:interval] = v }
        opt.parse!
      end
    end
  end
end
