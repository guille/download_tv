$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "download_tv"

require "minitest/autorun"


def create_dummy_config(in_path, config={})
	File.open(in_path, "wb") { |f| Marshal.dump(config, f) }
end