require "json"
require "mechanize"
require "date"
require "io/console"
require "fileutils"

require "download_tv/version"
require "download_tv/configuration"
require "download_tv/downloader"
require "download_tv/torrent"
require "download_tv/myepisodes"
require "download_tv/linkgrabber"
require "download_tv/subtitles"
Dir[File.join(__dir__, 'download_tv', 'grabbers', '*.rb')].each {|file| require file }
