# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "download_tv/version"

Gem::Specification.new do |s|
  s.name          = "download_tv"
  s.version       = DownloadTV::VERSION
  s.authors       = ["guille"]
  s.email         = ["guillerg96@gmail.com"]

  s.summary       = %q{DownloadTV is a tool that allows the user to find magnet links for tv show episodes. It accepts shows as arguments, from a file or it can integrate with your MyEpisodes account.}
  s.homepage      = "https://github.com/guille/download_tv"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end

  s.test_files  = `git ls-files -- test/*`.split($/)
  s.require_paths = ["lib"]

  s.executables   = ["tv"]
  s.default_executable = 'tv'

  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"

  s.add_dependency("json")
  s.add_dependency("mechanize")

  s.has_rdoc    = false
  s.license     = "MIT"
end