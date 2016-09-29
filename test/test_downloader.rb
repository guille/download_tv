require 'minitest/spec'
require 'minitest/autorun'
require 'date'
require_relative '../downloader'

describe ShowDownloader::Downloader do

	before do
		Dir.chdir(File.dirname(__FILE__))
	end

	describe "when creating the object" do
		it "should store the first parameter as @offset" do
			ShowDownloader::Downloader.new("foo").offset.must_equal 0
			ShowDownloader::Downloader.new(3).offset.must_equal 3
			ShowDownloader::Downloader.new.offset.must_equal 0
		end

		# it "should raise an error when no arguments are given" do
		#   -> {ShowDownloader::Downloader.new}.must_raise(ArgumentError)
		#   # -> {ShowDownloader::Downloader.new([])}.must_raise(ArgumentError)
		# end
	end

	it "should remove apostrophes and parens" do
		shows = ["Mr. Foo S01E02", "Bar (UK) S00E22", "Ignored S20E22", "Let's S05E03"]
		result = ["Mr. Foo S01E02", "Bar UK S00E22", "Lets S05E03"]
		ShowDownloader::Downloader.new.fix_names(shows).must_equal result
			
	end

	describe "the date file" do 
		dl = ShowDownloader::Downloader.new

		before do
			File.delete("date") if File.exist?("date")
		end

		it "should be created if it doesn't exist" do
			dl.check_date
			File.exist?("date").must_equal true
		end

		it "contains a date after running the method" do
			flag, date = dl.check_date
			flag.must_equal false
			date.must_equal (Date.today-1)
			Date.parse(File.read("date")).must_equal Date.today-1
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