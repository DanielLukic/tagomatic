require 'tagomatic/util/tags_hash_creator'

describe "TagsHashCreator" do

  before do
    @mapping = []
    @captures = []
    @matchdata = mock('MatchData', :captures => @captures)
    @creator = Tagomatic::Util::TagsHashCreator.new(@mapping, @matchdata)
  end

  it 'should map a single artist tag to its captured value' do
    @mapping << :artist
    @captures << 'artist'
    @creator.create_tags_hash.should == {:artist => 'artist'}
  end

  it 'should map tags to values in correct order' do
    @mapping << :artist << :album
    @captures << 'artist' << 'album'
    @creator.create_tags_hash.should == {:artist => 'artist', :album => 'album'}
  end

end
