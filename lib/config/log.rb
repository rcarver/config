module Config
  class Log

    def initialize(stream=StringIO.new)
      @stream = stream
      @indent_level = 0
      @indent_string = " " * 2
    end

    attr_accessor :indent_string

    def <<(input)
      input.split("\n").each do |line|
        @stream.puts "#{current_indent}#{line}"
      end
    end

    def indent(level=1)
      @indent_level += level
      begin
        yield
      ensure
        @indent_level -= level
      end
    end

  protected

    def current_indent
      @indent_string * @indent_level
    end

  end
end
