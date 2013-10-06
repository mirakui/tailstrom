require 'optparse'

module Tailstrom
  class OptionParser
    DEFAULTS = {
      :delimiter => "\t",
      :interval => 1,
      :mode => :stat,
      :order => :desc
    }.freeze

    def initialize
      @options = {}
      @options_from_file = {}
    end

    def parse(argv)
      parser = generate_parser
      parser.order! argv
      if infile = argv.shift
        @options[:static_infile] = open(infile, 'r')
      end
      @options = @options_from_file.merge @options
      DEFAULTS.merge @options
    end

    def generate_parser
      ::OptionParser.new do |opt|
        opt.banner = <<-END
tail -f access.log | #{$0} [OPTIONS]
#{$0} [OPTIONS] [file]
        END
        opt.on('-c file', '--config file', String, 'config file') do |v|
          @options_from_file = load_config v
        end
        opt.on('-f num', Integer, 'value field') do |v|
          @options[:field] = v
        end
        opt.on('-k num', Integer, 'key field') do |v|
          @options[:key] = v
        end
        opt.on('-d delimiter', String, 'delimiter') do |v|
          @options[:delimiter] = v
        end
        opt.on('-i interval', Integer, 'interval for stat mode') do |v|
          @options[:interval] = v
        end
        opt.on('-e file_or_string', '--in-filter file_or_string', String, 'input filtering') do |v|
          @options[:in_filter] = file_or_string v
        end
        opt.on('--map file_or_string', String, 'input mapping') do |v|
          @options[:map] = file_or_string v
        end
        opt.on('--out-filter file_or_string', String, 'output filtering') do |v|
          @options[:out_filter] = file_or_string v
        end
        opt.on('--sort file_or_string', String, 'output sorting') do |v|
          @options[:sort] = file_or_string v
        end
        opt.on('--order desc|asc', String, 'sorting order (default=desc)') do |v|
          @options[:order] = v.to_s.downcase == 'asc' ? :asc : :desc
        end
        opt.on('--stat', 'statistics mode (default)') do
          @options[:mode] = :stat
        end
        opt.on('--print', 'print line mode') do
          @options[:mode] = :print
        end
        opt.on('--version', 'show version') do
          require 'tailstrom/version'
          puts Tailstrom::VERSION
          exit 0
        end
      end
    end

    private
      def file_or_string(value)
        File.exist?(value) ? File.read(value) : value
      end

      def load_config(file)
        require 'yaml'
        argv = []
        hash = YAML.load File.read(file)
        hash.each do |k, v|
          argv << (k.length > 1 ? "--#{k}" : "-#{k}")
          argv << v unless v.is_a? TrueClass
        end
        parser = Tailstrom::OptionParser.new
        parser.parse argv
      end
  end
end
