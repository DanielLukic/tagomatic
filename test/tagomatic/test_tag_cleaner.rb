require 'helper'

require 'tagomatic/tag_cleaner'
require 'tagomatic/tags'

class TestTagCleaner < Test::Unit::TestCase
  include Tagomatic::Tags
  context "A TagCleaner" do
    setup do
      @tag_cleaner = Tagomatic::TagCleaner.new
      @test_tags = {ARTIST => 'artist', ALBUM => 'artist - album', TITLE => 'artist - album - 01 - title'}
    end

    should "remove artist name from album name" do
      result = @tag_cleaner.process(@test_tags)
      assert_equal 'artist', result[ARTIST]
      assert_equal 'album', result[ALBUM]
    end

    should "remove artist and album name from title" do
      result = @tag_cleaner.process(@test_tags)
      assert_equal '01 - title', result[TITLE]
    end
  end
end
