class String

  # Public: De-dent a string. Removes leading whitespace from each line of a
  # string, using the whitespace that exists on the first line as the
  # indentation level.
  #
  # Examples
  #
  #     str = <<-STR.dent
  #       First Line
  #         Indented Line
  #     STR
  #
  #     str.inspect # => "First Line\n  Indented Line\n"
  #
  # Returns a String.
  def dent
    lines = split("\n")
    head = self[/\A\s*/]
    tail = self[/\n*\Z/]
    dented = lines.map { |line| line.sub(/\A#{head}/, '') }
    dented.join("\n") + tail
  end
end
