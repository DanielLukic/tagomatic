class String

  def starts_with?(prefix)
    pattern = Regexp.new "^#{Regexp.escape(prefix)}"
    ( pattern =~ self ) == MATCHED_AT_CHAR_POSITION_ZERO
  end

  MATCHED_AT_CHAR_POSITION_ZERO = 0

end
