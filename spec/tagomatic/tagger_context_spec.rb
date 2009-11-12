require 'tagomatic/tagger_context'

describe "TaggerContext" do

  before do
    @options = mock('Tagomatic::Options')
    @logger = mock('Tagomatic::Logger')
    @context = Tagomatic::TaggerContext.new(@options, @logger)
  end

  it "should return nil for unknown properties" do
    @context.unknown_property.should == nil
  end

  it "should return a properties value after it has been set" do
    @context.property = 'okay'
    @context.property.should == 'okay'
  end

  it "should set file path plus an empty tags hash when reset for a new file path" do
    @context.reset_to TEST_FILE_PATH
    @context.file_path.should == TEST_FILE_PATH
    @context.tags.should == Hash.new
  end

  TEST_FILE_PATH = 'input/file.mp3'

end
