require 'tailstrom/tail_reader'

module Tailstrom
  module Command
    class Print
      def initialize(options)
        @infile = $stdin
        @options = options
      end

      def run
        reader = TailReader.new @infile, @options
        reader.each_line do |line|
          puts line[:line]
        end
      end
    end
  end
end
