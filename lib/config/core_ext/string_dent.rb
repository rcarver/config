class String

  # Public: Outdent and indent a string. With no arguments, outdents. With an
  # argument, outdents and then indents.
  #
  # indent_level - String or Integer used to ident (default: no indent).
  #
  # Examples
  #
  #     str = <<-STR.dent
  #       First Line
  #         Indented Line
  #     STR
  #     str.inspect # => "First Line\n  Indented Line\n"
  #
  #     str = <<-STR.dent(2)
  #         First Line
  #           Indented Line
  #     STR
  #     str.inspect # => "  First Line\n    Indented Line\n"
  #
  # Returns a String.
  def dent(indent_level = nil)
    if indent_level
      outdent.indent(indent_level)
    else
      outdent
    end
  end

  # Public: Outdent a string. Removes leading whitespace from each line of a
  # string by removing the smallest amount of leading whitespace found on
  # any line of the string.
  #
  # Examples
  #
  #     str = <<-STR.outdent
  #       First Line
  #         Indented Line
  #     STR
  #     str.inspect # => "First Line\n  Indented Line\n"
  #
  #     str = <<-STR.outdent
  #         Indented Line
  #       Second Line
  #     STR
  #     str.inspect # => "  Indented Line\nSecond Line\n"
  #
  # Returns a String.
  def outdent
    lines = split("\n")
    head = lines.map { |line| line[/\A\s*/] }.min
    tail = self[/\n*\Z/]
    dented = lines.map { |line| line.sub(/\A#{head}/, '') }
    dented.join("\n") + tail
  end

  # Public: Indent a string. Addes leading whitespace to each line.
  #
  # level - String or Integer used to indent. A String is used as is,
  #         an integer indicates how many spaces to indent.
  #
  # Examples
  #
  #   str = <<-STR.indent(2)
  #   First Line
  #     Second Line
  #   STR
  #   str.inspect # => "  First Line\n    Second Line\n"
  #
  #   str = <<-STR.indent("* ")
  #   First Line
  #     Second Line
  #   STR
  #   str.inspect # => "* First Line\n*   Second Line\n"
  #
  # Returns a String.
  def indent(level)
    level_str = case level
    when String then level
    when Fixnum then " " * level
    else raise ArgumentError, "#{level.inspect} is not a valid indent level"
    end
    lines = split("\n")
    tail = self[/\n*\Z/]
    lines.map { |line| "#{level_str}#{line}" }.join("\n") + tail
  end
end
