require 'minitest/autorun'
# require 'date'
require_relative '../torrent'

describe ShowDownloader::Torrent do
	before do
		@t = ShowDownloader::Torrent.new
	end

	describe "when creating the object" do
		it "will have some grabbers" do
			@t.g_names.empty?.must_equal false
			@t.g_instances.empty?.must_equal false
			@t.n_grabbers.must_be :>, 0
		end

		it "will have the right amount of grabbers" do
			# Initiakize calls change_grabbers
			@t.n_grabbers.must_equal @t.g_names.size + 1
			@t.g_instances.size.must_equal 1
			
		end

		it "will populate the instances" do
			@t.n_grabbers.times.each { @t.change_grabbers }
			@t.g_names.empty?.must_equal true
			@t.g_instances.empty?.must_equal false
			@t.g_instances.size.must_equal @t.n_grabbers
			
		end

		it "will return an empty string when torrent can't be found" do
			@t.get_link("Totally Fake Show askjdgsaudas", true).must_equal ""

		end

		
	end
end
