require "test_helper"

describe DownloadTV::Configuration do
	config_path = File.realdirpath("#{__dir__}/test_config")

	before do
		Dir.chdir(__dir__)
	end

	after do
		File.delete(config_path) if File.exist?(config_path)
	end

	describe "when the file already exists" do
		it "will load the existing configuration (blank)" do
			create_dummy_config(config_path)

			c = DownloadTV::Configuration.new(path: config_path)
			c.content.must_equal ({path: config_path})
		end

		it "will load the existing configuration (existing)" do
			create_dummy_config(config_path, auto: false, myepisodes_user: "dummy")

			c = DownloadTV::Configuration.new(path: config_path)
			c.content.must_equal ({path: config_path, auto: false, myepisodes_user: "dummy"})
		end

		it "will get overwritten by the parameters given" do
			create_dummy_config(config_path, myepisodes_user: "dummy")

			c = DownloadTV::Configuration.new(path: config_path, myepisodes_user: "fake")
			c.content.must_equal ({path: config_path, myepisodes_user: "fake"})
		end
	end

	# describe "when the file doesn't exist" do
	# 	it "will create a new one" do
	# 		# Send stuff to stdin
	# 		flunk
	# 		DownloadTV::Configuration.new(path: config_path)
	# 		File.exist?(config_path).must_equal true			
	# 	end

	# 	it "will trigger a configuration change when asked to" do
	# 		DownloadTV::Configuration.new(path: config_path, true)
	# 	end
	# end

	# test [:ignored] gets turned to lowercase

end