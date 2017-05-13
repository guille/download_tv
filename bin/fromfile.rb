#!/usr/bin/env ruby

require_relative '../downloader'

begin
	dl = ShowDownloader::Downloader.new
	dl.download_from_file(ARGV[0])

rescue Interrupt
	puts "Interrupt signal detected. Exiting..."
end