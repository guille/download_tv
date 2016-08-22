require 'minitest/spec'
require 'minitest/autorun'
require_relative '../downloader'

describe ShowDownloader::Downloader do

  describe "when creating the object" do
    it "should store the first parameter as @app" do
      ShowDownloader::Downloader.new(["foo"]).app.must_equal "foo"
      ShowDownloader::Downloader.new(["foo", 3]).app.must_equal "foo"
      ShowDownloader::Downloader.new([]).app.must_be_nil
    end

    it "should raise an error when no arguments are given" do
      -> {ShowDownloader::Downloader.new}.must_raise(ArgumentError)
      # -> {ShowDownloader::Downloader.new([])}.must_raise(ArgumentError)
    end

    
  end

  it "should remove dots and parens" do
      shows = ["Mr. Foo S01E02", "Bar (UK) S00E22", "SkipThis S20E22"]
      result = ["Mr Foo S01E02", "Bar UK S00E22"]
      ShowDownloader::Downloader.new([]).fix_names(shows).must_equal result
      
  end

  describe "the date file" do 
    before do
      File.delete("date") if File.exist?("date")

    end

    it "should be created if it doesn't exist" do
      ShowDownloader::Downloader.new([]).check_date
      File.exist?("date").must_equal true
      
    end
    
  end

  # must raise AuthenticationError
  # random string must raise torrent not found
  # also, add it to the @@pending array
  # querying eztv and torrentapi should return 200 OK

  # it has to be called from /test
  # otherwise it will use the wrong date/ignored files
  # possible solution: Dir.chdir before running the test


end