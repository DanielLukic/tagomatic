require 'tagomatic/tagger_chain/tag_cleaner'

require 'tagomatic/tags'
include Tagomatic::Tags

describe 'Tagomatic::TaggerChain::TagCleaner' do

  before do
    @tags = {ARTIST => 'artist', ALBUM => 'artist - album', TITLE => 'artist - album - 01 - title'}
    @context = mock('TaggerContext', :tags => @tags)
    @tag_cleaner = Tagomatic::TagCleaner.new :cleantags => true
  end

  it "should remove artist name from album name" do
    @tag_cleaner.process @context
    @tags[ARTIST].should == 'artist'
    @tags[ALBUM].should == 'album'
  end

  it "should remove artist and album name from title" do
    @tag_cleaner.process @context
    @tags[TITLE].should == '01 - title' 
  end

end
