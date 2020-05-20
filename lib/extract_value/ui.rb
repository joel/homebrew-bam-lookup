# frozen_string_literal: true

require 'optparse'

module ExtractValue
  class OptparseExample
    class ScriptOptions
      attr_accessor :expression, :verbose

      def initialize
        self.verbose = false
      end

      def define_options(parser)
        parser.banner = "Usage: ExtractValue [options]"
        parser.separator ""
        parser.separator "Specific options:"

        # add additional options
        expression_option(parser)

        boolean_verbose_option(parser)

        parser.separator ""
        parser.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        parser.on_tail("-h", "--help", "Show this message") do
          puts parser
          exit
        end
        # Another typical switch to print the version.
        parser.on_tail("--version", "Show version") do
          puts ExtractValue::VERSION
          exit
        end
      end

      def expression_option(parser)
        parser.on('-e EXPRESSION', '--expression EXPRESSION', '[REQUIRED] What label you are looking for', String) do |expression|
          self.expression = expression
        end
      end

      def boolean_verbose_option(parser)
        # Boolean switch.
        parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          self.verbose = v
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
  end  # class OptparseExample

  class Ui
    def initialize
      example = OptparseExample.new
      @options = example.parse(ARGV)

      if !options.expression
        help(example.option_parser)
        exit(1)
      end
    end

    def search
      ExtractValue::Main.new(expression: options.expression, verbose: options.verbose).extract_value
    end

    def help(opts)
      puts(opts)
    end

    attr_reader :options
  end
end
