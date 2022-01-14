# frozen_string_literal: true

require 'set'
require 'json'
require 'mechanize'
require 'date'
require 'io/console'
require 'fileutils'

require 'download_tv/version'
require 'download_tv/configuration'
require 'download_tv/downloader'
require 'download_tv/torrent'
require 'download_tv/filterer'
require 'download_tv/myepisodes'
require 'download_tv/linkgrabber'

module DownloadTV
  USER_AGENT = "DownloadTV #{DownloadTV::VERSION}"

  class NoTorrentsError < StandardError; end

  class NoSubtitlesError < StandardError; end
end

Dir[File.join(__dir__, 'download_tv', 'grabbers', '*.rb')].sort.each { |file| require file }
