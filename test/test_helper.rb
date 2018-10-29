$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'download_tv'
require 'minitest/autorun'

def create_dummy_config(in_path, config = {})
  config[:version] = DownloadTV::VERSION unless config[:version]
  File.write(in_path, JSON.generate(config))
end

def run_silently
  previous_stdout = $stdout
  $stdout = StringIO.new
  previous_stderr = $stderr
  $stderr = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = previous_stdout
  $stderr = previous_stderr
end
