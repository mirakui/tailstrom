require 'optparse'
require 'tailstrom/counter_collection'
require 'thread'

module Tailstrom
  module Command
    class Stat
      def initialize(argv)
        @infile = $stdin
        @counters = CounterCollection.new
        parse_option argv
      end

      def run
        Thread.start {
          loop do
            while line = @infile.gets
              line = line.chomp
              parse_line line
            end
            sleep 0.1
          end
        }
        loop do
          puts @counters[:all].avg unless @counters.empty?
          @counters.clear
          sleep 1
        end
      end

      def parse_line(line)
        columns = line.split @options[:delimiter]
        value = columns[@options[:field]].to_f if @options[:field]
        @counters[:all] << value
      end

      def parse_option(argv)
        @options = {
          :delimiter => "\t"
        }
        opt = OptionParser.new(argv)
        opt.on('-f [field]', Integer) {|v| @options[:field] = v }
        opt.on('-d [delimiter]', String) {|v| @options[:delimiter] = v }
        opt.parse!
      end
    end
  end
end
