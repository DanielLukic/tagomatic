require 'tagomatic/tagger_chain/url_remover'

describe Tagomatic::UrlRemover do

  before do
    @tags = {:a => 'the artist', :b => 'the album - www.albumses.net', :t => 'title track - www.nowhere.org by lupo'}
    @context = mock('TaggerContext', :tags => @tags)
    @url_remover = Tagomatic::UrlRemover.new :removeurls => true
  end

  it "should remove artist name from album name" do
    @url_remover.process @context
    @tags[:a].should == 'the artist'
    @tags[:b].should == 'the album - '
    @tags[:t].should == 'title track -'
  end

end
