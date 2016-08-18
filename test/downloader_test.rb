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

end