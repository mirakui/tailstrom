module Tailstrom
  class TailReader
    def initialize(infile, options={})
      @infile = infile
      @options = options
    end

    def each_line
      @infile.each_line do |line|
        result = parse_line(line)
        yield result if result
      end
    end

    def parse_line(line)
      columns = line.split @options[:delimiter]
      value = @options[:field] ? columns[@options[:field]] : line
      value = value =~ /\./ ? value.to_f : value.to_i

      if @options[:filter]
        v, cols = value, columns # shorthands
        return nil unless binding.eval(@options[:filter])
      end

      { :line => line, :columns => columns, :value => value }
    end
  end
end
