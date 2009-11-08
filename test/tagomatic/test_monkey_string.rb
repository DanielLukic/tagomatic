require 'helper'

require 'monkey/string'

class TestMonkeyString < Test::Unit::TestCase
  context "A monkey-patched String" do
    setup do
      @string = "left and right"
    end

    should "match prefix properly" do
      assert @string.starts_with?("left")
    end

    should "not match wrong prefix" do
      assert !@string.starts_with?("and")
    end

    should "match suffix properly" do
      assert @string.ends_with?("right")
    end

    should "not match wrong suffix" do
      assert !@string.ends_with?("and")
    end
  end
end
