require 'tagomatic/util/again_tags_validator'

require 'tagomatic/tags'
include Tagomatic::Tags

describe "AgainTagsValidator" do

  before do
    @tags = Hash.new
    @validator = Tagomatic::Util::AgainTagsValidator.new(@tags)
  end

  it "should be valid if base and again tag are empty" do
    artist_valid?.should == true
  end

  it "should be valid if base tag is set but again tag is not" do
    @tags[ARTIST] = 'artist'
    artist_valid?.should == true
  end

  it "should be valid if base tag and again tag match" do
    @tags[ARTIST] = 'artist'
    @tags[ARTIST_AGAIN] = 'artist'
    artist_valid?.should == true
  end

  it "should fail if base tag and again tag do not match" do
    @tags[ARTIST] = 'artist'
    @tags[ARTIST_AGAIN] = 'album'
    artist_valid?.should == false
  end

  def artist_valid?
    @validator.valid_double_match_with_same_value?(ARTIST, ARTIST_AGAIN)
  end

  describe 'with both artist and album base tag set' do

    before do
      @tags[ARTIST] = 'artist'
      @tags[ALBUM] = 'album'
    end

    it "should be valid if again tags are empty" do
      valid?.should == true
    end

    it "should be valid if only artist again tag is set and matches" do
      @tags[ARTIST_AGAIN] = 'artist'
      valid?.should == true
    end

    it "should be valid if only album again tag is set and matches" do
      @tags[ALBUM_AGAIN] = 'album'
      valid?.should == true
    end

    it "should be valid if both again tags match" do
      @tags[ARTIST_AGAIN] = 'artist'
      @tags[ALBUM_AGAIN] = 'album'
      valid?.should == true
    end

    it "should fail if artist again tag does not match" do
      @tags[ARTIST_AGAIN] = 'title'
      valid?.should == false
    end

    it "should fail if album again tag does not match" do
      @tags[ALBUM_AGAIN] = 'title'
      valid?.should == false
    end

    it "should fail if artist matches but album does not" do
      @tags[ARTIST_AGAIN] = 'artist'
      @tags[ALBUM_AGAIN] = 'title'
      valid?.should == false
    end

    def valid?
      @validator.valid_constraints?
    end

  end

end
