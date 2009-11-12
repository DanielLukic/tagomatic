require 'tagomatic/tagger_chain/tag_normalizer'

describe Tagomatic::TagNormalizer do

  before do
    @tags = {:artist => 'the artist', :album => 'the album - ', :title => '. title track -  by lupo -'}
    @context = mock('TaggerContext', :tags => @tags)
    @tag_normalizer = Tagomatic::TagNormalizer.new
  end

  it "should remove artist name from album name" do
    @tag_normalizer.process @context
    @tags[:artist].should == 'The Artist'
    @tags[:album].should == 'The Album'
    @tags[:title].should == 'Title Track By Lupo'
  end

end
