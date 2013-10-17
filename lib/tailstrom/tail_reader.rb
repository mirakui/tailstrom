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
      key = value = nil
      in_filter = @options[:in_filter]

      _scripts = []

      if @options[:map]
        _scripts << @options[:map]
        _scripts << 'value=format_value(value)'
      end

      if @options[:key]
        _scripts << index_or_eval('key', 'col', @options[:key])
      end

      if @options[:value]
        _scripts << index_or_eval('value', 'col', @options[:value])
        _scripts << 'value=format_value(value)'
      end

      if in_filter
        _scripts << in_filter
        return nil unless eval _scripts.join(';')
      end

      eval _scripts.join(';')
      { :line => line, :columns => col, :key => key, :value => value }
    end

    def format_value(value)
      value =~ /\./ ? value.to_f : value.to_i
    end

    def index_or_eval(var, col, idx)
      case idx
      when Integer
        "#{var}=col[#{idx}]"
      when String
        "#{var}=#{idx}"
      end
    end
    private :index_or_eval
  end
end
