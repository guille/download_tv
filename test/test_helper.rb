$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "download_tv"

require "minitest/autorun"


def create_dummy_config(in_path, config={})
	config[:version] = DownloadTV::VERSION if !config[:version]
	File.open(in_path, "wb") { |f| Marshal.dump(config, f) }
end

def run_silently
	previous_stdout, $stdout = $stdout, StringIO.new
	yield
	$stdout.string
ensure
	$stdout = previous_stdout
end