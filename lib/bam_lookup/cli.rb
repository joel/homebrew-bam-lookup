# frozen_string_literal: true

require 'optparse'

module BamLookup
  class OptparseExample
    class ScriptOptions
      attr_accessor :expression, :verbose, :write, :min, :max, :label, :trunk, :source_file, :source_directory, :date_fallback

      def initialize
        self.verbose = false
        self.write = false
        self.max = Float::INFINITY
        self.min = -Float::INFINITY
        self.trunk = 100
        self.source_file = false
        self.source_directory = nil
        self.date_fallback = false
      end

      def define_options(parser)
        parser.banner = 'Usage: bin/lookup --expression agua,endesa ---trunk 20 --min -200 --max 0 --label Agua [options]'
        parser.separator ''
        parser.separator 'Specific options:'

        # add additional options
        expression_option(parser)
        max_option(parser)
        min_option(parser)
        label_option(parser)
        trunk_option(parser)
        source_directory_option(parser)

        boolean_verbose_option(parser)
        boolean_write_option(parser)
        boolean_source_file_option(parser)
        boolean_date_fallback(parser)

        parser.separator ''
        parser.separator 'Common options:'

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
          exit
        end
        # Another typical switch to print the version.
        parser.on_tail('--version', 'Show version') do
          puts BamLookup::VERSION
          exit
        end
      end

      def expression_option(parser)
        parser.on('-e EXPRESSION', '--expression EXPRESSION', '[REQUIRED] What label you are looking for, coma as separator (OR)', String) do |expression|
          self.expression = expression
        end
      end

      def max_option(parser)
        parser.on('-m MAX', '--max MAX', '[OPTIONAL] Keep only amount less than', Integer) do |max|
          self.max = max
        end
      end

      def min_option(parser)
        parser.on('-a MIN', '--min MIN', '[OPTIONAL] Keep only amount greater than', Integer) do |min|
          self.min = min
        end
      end

      def trunk_option(parser)
        parser.on('-t TRUNK', '--trunk TRUNK', '[OPTIONAL] Trunk label', Integer) do |trunk|
          self.trunk = trunk
        end
      end

      def label_option(parser)
        parser.on('-l LABEL', '--label LABEL', '[OPTIONAL] Labelled the items', String) do |label|
          self.label = label
        end
      end

      def source_directory_option(parser)
        parser.on('-s SOURCE_DIRECTORY', '--source_directory SOURCE_DIRECTORY', '[OPTIONAL] Where the CVS files are', String) do |source_directory|
          self.source_directory = source_directory
        end
      end

      def boolean_verbose_option(parser)
        # Boolean switch.
        parser.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          self.verbose = v
        end
      end

      def boolean_write_option(parser)
        parser.on('-w', '--[no-]write', 'Write the result in csv') do |w|
          self.write = w
        end
      end

      def boolean_source_file_option(parser)
        parser.on('-d', '--[no-]source_file', 'Add Source file') do |source_file|
          self.source_file = source_file
        end
      end

      def boolean_date_fallback(parser)
        parser.on('-b', '--[no-]date_fallback', 'Guess is format unknown') do |date_fallback|
          self.date_fallback = date_fallback
        end
      end
    end

    #
    # Return a structure describing the options.
    #
    def parse(args)
      # The options specified on the command line will be collected in
      # *options*.
      @options = ScriptOptions.new
      @option_parser = OptionParser.new do |parser|
        @options.define_options(parser)
        parser.parse!(args)
      end
      @options
    end

    attr_reader :parser, :options, :option_parser
  end # class OptparseExample

  class Cli
    def initialize
      example = OptparseExample.new
      @options = example.parse(ARGV)

      unless options.expression
        help(example.option_parser)
        exit(1)
      end
    end

    def lookup
      BamLookup.configure do |conf|
        conf.verbose = options.verbose
        conf.options = options
      end
      BamLookup::Main.new(options).bam_lookup
    end

    def help(opts)
      puts(opts)
    end

    attr_reader :options
  end
end
