module Tailstrom
  class Table
    def initialize(schema)
      @schema = schema
      @out = $stdout
    end

    def print_row(*cols)
      cols.each_with_index do |col, i|
        col_schema = @schema[i]
        num_str = col ? num_with_delim(col) : '-'
        print ' ' if i > 0
        align = col_schema[:align].to_s == 'left' ? '-' : nil
        printf "%#{align}#{col_schema[:width]}s", num_str
      end
      self.puts
    end

    def print_header
      border = head = ''
      @schema.each_with_index do |col, i|
        if i > 0
          border += '-'
          head   += ' '
        end
        align = col[:align].to_s == 'left' ? '-' : nil
        border += '-' * col[:width]
        head += "%#{align}#{col[:width]}s" % col[:name]
      end
      self.puts border, head, border
    end

    def puts(*args)
      @out.puts *args
    end

    private
      def num_with_delim(num)
        head, tail = num.to_s.split('.')
        head.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
        if tail
          "#{head}.#{tail[0..2]}"
        else
          head
        end
      end
  end
end

if $0 == __FILE__
  nums = [
459938.0869565217,
588316.4761904762,
459265.652173913,
473729.63636363635,
625076.2857142857,
461625.76,
412747.04761904763,
367196.3,
0.125,
9.50,
10.1,
100,
100
  ]

  schema = [
    { :name => 'min', :width => 15 },
    { :name => 'max', :width => 15 },
  ]

  table = Tailstrom::Table.new schema
  table.print_header
  nums.each do |num|
    table.print_row num, num
  end
end
