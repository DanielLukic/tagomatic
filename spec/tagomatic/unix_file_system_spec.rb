require 'tagomatic/unix_file_system'

describe "UnixFileSystem" do

  before do
    @file_system = Tagomatic::UnixFileSystem.new
  end

  it "should not changed a clean file name" do
    @file_system.quoted_file_path('test').should == 'test'
  end

  describe 'when quoting a file path' do

    it "should quote bad characters" do
      @file_system.quoted_file_path(%q[`it$is'me!]).should == %q[\`it\$is\'me\!]
    end

    it "should quote spaces, too" do
      @file_system.quoted_file_path(%q[`it is me!]).should == %q[\`it\ is\ me\!]
    end

    it "should quote multiple bad characters in a row, too" do
      @file_system.quoted_file_path(%q[`it   is me!!!]).should == %q[\`it\ \ \ is\ me\!\!\!]
    end

  end

  describe 'when cleaning a file path' do

    it "should remove bad characters" do
      @file_system.cleaned_file_path(%q[`it$is'me!]).should == %q[itisme]
    end

    it "should leave the spaces untouched" do
      @file_system.cleaned_file_path(%q[`it is me!]).should == %q[it is me]
    end

  end

end
