require 'helper'

require 'tagomatic/tag_normalizer'

class TestTagNormalizer < Test::Unit::TestCase
  context "A TagNormalizer" do
    setup do
      @tag_normalizer = Tagomatic::TagNormalizer.new
    end

    should "do something" do
      test_tags = {:a => 'the artist', :b => 'the album - ', :t => '. title track -  by lupo -'}
      result = @tag_normalizer.process(test_tags)
      assert_equal 'The Artist', result[:a]
      assert_equal 'The Album', result[:b]
      assert_equal 'Title Track By Lupo', result[:t]
    end
  end
end
