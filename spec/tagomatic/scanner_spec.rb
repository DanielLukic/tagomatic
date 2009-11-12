require 'tagomatic/local_options'
require 'tagomatic/scanner'
require 'tagomatic/scanner_chain'
require 'tagomatic/unix_file_system'

require 'tagomatic/scanner_chain/mp3_file_path_yielder'

describe Tagomatic::Scanner do

  before do
    @options = {}
    @file_system = Tagomatic::UnixFileSystem.new
    @scanner_chain = Tagomatic::ScannerChain.new
    @scanner_chain.append Tagomatic::Mp3FilePathYielder.new(@file_system)
    @scanner = Tagomatic::Scanner.new(@options, @file_system, @scanner_chain)
    @result = []
  end

  shared_examples_for 'scanning single input file' do

    it "yields single file if this is the only input" do
      @scanner.each_mp3('test/data/scanner_spec/test1.mp3') { |f| collect f }
      @result.sort.should == ['test1.mp3']
    end

  end

  describe 'scanning with :recurse => false' do

    before do
      @options[:recurse] = false
    end

    it "yields nothing if scanning folder" do
      @scanner.each_mp3(TEST_DATA_FOLDER) { |f| collect f }
      @result.sort.should == []
    end

    it_should_behave_like 'scanning single input file'

  end

  describe 'scanning with :recurse => true' do

    before do
      @options[:recurse] = true
    end

    it "yields all taggable files when scanning with :recurse option on" do
      @scanner.each_mp3(TEST_DATA_FOLDER) { |f| collect f }
      @result.sort.should == ['cheese.mp3', 'test1.mp3', 'test2.mp3', 'toast.mp3']
    end

    it "yields absolute file pathes" do
      @scanner.each_mp3(TEST_DATA_FOLDER) do |mp3_file_path|
         has_absolute_path?(mp3_file_path).should == true
      end
    end

    it_should_behave_like 'scanning single input file'

  end

  def collect(mp3_file_path)
    @result ||= []
    @result << File.basename(mp3_file_path)
  end

  def has_absolute_path?(mp3_file_path)
    path_prefix = File.expand_path(TEST_DATA_FOLDER)
    mp3_file_path.starts_with?(path_prefix)
  end

  TEST_DATA_FOLDER = 'test/data/scanner_spec'

end
