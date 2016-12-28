#!/usr/bin/env ruby

require_relative '../downloader'

dl = ShowDownloader::Downloader.new
dl.download_from_file(ARGV[0])
