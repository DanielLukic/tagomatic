require 'tagomatic/tagger_context'

describe "TaggerContext" do

  before do
    @context = Tagomatic::TaggerContext.new
  end

  it "should return nil for unknown properties" do
    @context.unknown_property.should == nil
  end

  it "should return a properties value after it has been set" do
    @context.property = 'okay'
    @context.property.should == 'okay'
  end

  it "should set input and output file name plus an empty tags hash when reset for a new file path" do
    @context.reset_to INPUT_FILE_PATH
    @context.input_file_path.should == INPUT_FILE_PATH
    @context.output_file_path.should == INPUT_FILE_PATH
    @context.tags.should == Hash.new
  end

  INPUT_FILE_PATH = 'input/file.mp3'

end
