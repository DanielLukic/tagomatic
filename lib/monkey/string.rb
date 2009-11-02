class String

  def starts_with?(prefix)
    pattern = Regexp.new "^#{Regexp.escape(prefix)}"
    not ( pattern =~ self ).nil?
  end

  def ends_with?(suffix)
    pattern = Regexp.new "#{Regexp.escape(suffix)}$"
    not ( pattern =~ self ).nil?
  end

end
