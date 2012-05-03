module Config
  class Log

    def initialize(stream=StringIO.new)
      @stream = stream
      @indent_level = 0
      @indent_string = " " * 2
      @color = true
    end

    attr_accessor :indent_string

    # Public: Write to the log.
    #
    # input - String to write. Multiline strings are split on newline
    #         and written one line at a time to maintain the current
    #         indent.
    #
    # Returns nothing.
    def <<(input)
      input.split("\n").each do |line|
        @stream.puts "#{current_indent}#{line}"
      end
    end

    # Public: Increase the current indent level for the life of a block
    #
    # level - The number of indents to increase (default: 1).
    #
    # Examples
    #
    #     log << "hello"
    #     log.indent do
    #       log << "indented"
    #     end
    #     log << "world"
    #
    #     # =>
    #     # hello
    #     #   indented
    #     # world
    #
    # Returns nothing.
    def indent(level=1)
      @indent_level += level
      begin
        yield
      ensure
        @indent_level -= level
      end
    end


    RESET =    "\033[0m"
    FOREGROUND = {
      black:   "\033[30m",
      red:     "\033[31m",
      green:   "\033[32m",
      brown:   "\033[33m",
      blue:    "\033[34m",
      magenta: "\033[35m",
      cyan:    "\033[36m",
      white:   "\033[37m"
    }

    # Public: Enable or disable colorized output.
    #
    # enabled - Boolean true if colorizing is allowed.
    attr_writer :color

    # Public: Colorize a string. If `enable_color` is false, then no
    # color is applied.
    #
    # str        - String to colorize.
    # foreground - Symbol name of the color.
    #
    # Returns a String wrapped in ANSI color codes.
    def colorize(str, foreground)
      if @color
        fore = FOREGROUND[foreground] or raise ArgumentError, "Unknown foreground color #{foreground.inspect}"
        "#{fore}#{str}#{RESET}"
      else
        str
      end
    end

  protected

    def current_indent
      @indent_string * @indent_level
    end

  end
end
