module Tailstrom
  class TailReader
    def initialize(infile, options={})
      @infile = infile
      @options = options
    end

    def each_line
      @infile.each_line do |line|
        line.chomp!
        result = parse_line(line)
        yield result if result
      end
    end

    def parse_line(line)
      col = line.split @options[:delimiter]
      value = @options[:field] ? col[@options[:field]] : line
      value = format_value value
      key = @options[:key] ? col[@options[:key]] : :nil
      filter = @options[:filter]

      if @options[:map]
        binding.eval(@options[:map])
        value = format_value value
      end

      if filter
        return nil unless binding.eval(filter)
      end

      { :line => line, :columns => col, :key => key, :value => value }
    end

    def format_value(value)
      value =~ /\./ ? value.to_f : value.to_i
    end
  end
end
