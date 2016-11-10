require 'minitest/autorun'
# require 'date'
require_relative '../downloader'

Dir.chdir(File.dirname(__FILE__))

describe ShowDownloader::Downloader do

	describe "when creating the object" do
		it "should store the first argument as @offset" do
			ShowDownloader::Downloader.new("foo").offset.must_equal 0
			ShowDownloader::Downloader.new(3).offset.must_equal 3
		end

		it "should set offset to 0 if no argument is given" do
			ShowDownloader::Downloader.new.offset.must_equal 0
		end

	end

	describe "the fix_names function" do
		it "should remove apostrophes and parens" do
			shows = ["Mr. Foo S01E02", "Bar (UK) S00E22", "Let's S05E03"]
			result = ["Mr. Foo S01E02", "Bar UK S00E22", "Lets S05E03"]
			ShowDownloader::Downloader.new.fix_names(shows).must_equal result
		end

		it "should remove ignored shows" do
			shows = ["Mr. Foo S01E02", "Bar (UK) S00E22", "Ignored S20E22", "Let's S05E03"]
			result = ["Mr. Foo S01E02", "Bar UK S00E22", "Lets S05E03"]
			ShowDownloader::Downloader.new.fix_names(shows).must_equal result
		end
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
			date = dl.check_date
			date.must_equal (Date.today-1)
			Date.parse(File.read("date")).must_equal Date.today-1
		end

		it "exits the script when up to date" do
			File.write("date", Date.today)
			begin
				dl.check_date
				flunk
			rescue SystemExit
			
			end
		end
		
	end

end