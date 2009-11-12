require 'tagomatic/unix_file_system'

describe "UnixFileSystem" do

  before do
    @file_system = Tagomatic::UnixFileSystem.new
  end

  it "should not changed a clean file name" do
    @file_system.quoted_file_path('test').should == 'test'
  end

  it "when quoting a file path should quote bad characters" do
    @file_system.quoted_file_path(%q[`it$is'me!]).should == %q[\`it\$is\'me\!]
  end

  it "when cleaning a file path should remove bad characters" do
    @file_system.cleaned_file_path(%q[`it$is'me!]).should == %q[itisme]
    @file_system.cleaned_file_path(%q[`it is me!]).should == %q[it is me]
  end

end
