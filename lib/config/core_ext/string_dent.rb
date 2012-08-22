class String

  # Public: De-dent a string. Removes leading whitespace from each line of a
  # string by removing the smallest amount of leading whitespace found on
  # any line of the string.
  #
  # Examples
  #
  #     str = <<-STR.dent
  #       First Line
  #         Indented Line
  #     STR
  #     str.inspect # => "First Line\n  Indented Line\n"
  #
  #     str = <<-STR.dent
  #         Indented Line
  #       Second Line
  #     STR
  #     str.inspect # => "  Indented Line\nSecond Line\n"
  #
  # Returns a String.
  def dent
    lines = split("\n")
    head = lines.map { |line| line[/\A\s*/] }.min
    tail = self[/\n*\Z/]
    dented = lines.map { |line| line.sub(/\A#{head}/, '') }
    dented.join("\n") + tail
  end
end
