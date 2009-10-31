class String

  def starts_with?(prefix)
    pattern = Regexp.new "^#{Regexp.escape(prefix)}"
    pattern =~ self
  end

end
