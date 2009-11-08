require 'helper'

require 'tagomatic/tag_cleaner'

class TestTagCleaner < Test::Unit::TestCase
  context "A TagCleaner" do
    setup do
      @tag_cleaner = Tagomatic::TagCleaner.new
      @test_tags = {'a' => 'artist', 'b' => 'artist - album', 't' => 'artist - album - 01 - title'}
    end

    should "remove artist name from album name" do
      result = @tag_cleaner.process(@test_tags)
      assert_equal 'artist', result['a']
      assert_equal 'album', result['b']
    end

    should "remove artist and album name from title" do
      result = @tag_cleaner.process(@test_tags)
      assert_equal '01 - title', result['t']
    end
  end
end
