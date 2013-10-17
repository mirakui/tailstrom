module Tailstrom
  class TailReader
    def initialize(infile, options={})
      @infile = infile
      @options = options
    end

    def each_line(&block)
      if @options[:async]
        Thread.new { _each_line &block }
      else
        _each_line &block
      end
    end

    def _each_line
      @eof = false
      @infile.each_line do |line|
        line.chomp!
        result = parse_line(line)
        yield result if result
      end
      @eof = true
    end
    private :_each_line

    def eof?
      @eof
    end

    def parse_line(line)
      col = line.split @options[:delimiter]
      value = @options[:field] ? col[@options[:field]] : line
      value = format_value value
      key = @options[:key] ? col[@options[:key]] : :nil
      in_filter = @options[:in_filter]

      scripts = []

      if @options[:map]
        scripts << @options[:map]
        scripts << 'value=format_value(value)'
      end

      if in_filter
        scripts << in_filter
        return nil unless eval scripts.join(';')
      end

      eval scripts.join(';')
      { :line => line, :columns => col, :key => key, :value => value }
    end

    def format_value(value)
      value =~ /\./ ? value.to_f : value.to_i
    end
  end
end
