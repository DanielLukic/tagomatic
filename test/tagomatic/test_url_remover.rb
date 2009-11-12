require 'helper'

require 'tagomatic/url_remover'

class TestUrlRemover < Test::Unit::TestCase
  context "A UrlRemover" do
    setup do
      @url_remover = Tagomatic::UrlRemover.new :removeurls => true
    end

    should "remove URLs from tag values" do
      test_tags = {:a => 'the artist', :b => 'the album - www.albumses.net', :t => 'title track - www.nowhere.org by lupo'}
      result = @url_remover.process(test_tags)
      assert_equal 'the artist', result[:a]
      assert_equal 'the album - ', result[:b]
      assert_equal 'title track - ', result[:t]
    end
  end
end
