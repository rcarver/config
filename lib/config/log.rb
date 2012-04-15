module Config
  class Log

    def initialize(stream=StringIO.new)
      @stream = stream
      @indent_level = 0
      @indent_string = " " * 2
    end

    attr_accessor :indent_string

    def <<(input)
      @stream.puts "#{current_indent}#{input}"
    end

    def indent
      @indent_level += 1
      begin
        yield
      ensure
        @indent_level -= 1
      end
    end

  protected

    def current_indent
      @indent_string * @indent_level
    end

  end
end
