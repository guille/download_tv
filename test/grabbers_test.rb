# frozen_string_literal: true

require 'test_helper'

describe DownloadTV::LinkGrabber do
  grabbers = DownloadTV::Torrent.new.grabbers
  instances = grabbers.map { |g| (DownloadTV.const_get g).new }

  instances.each do |grabber|
    describe grabber do
      next unless grabber.online?

      it 'will have a url attribute on creation' do
        grabber.url.wont_be_nil
      end

      it "will raise NoTorrentsError when torrent can't be found" do
        notfound = -> { grabber.get_links('Totally Fake Show askjdgsaudas') }
        notfound.must_raise DownloadTV::NoTorrentsError
      end

      it 'will return an array with names and links of results when a torrent can be found' do
        result = grabber.get_links('Game Of Thrones S04E01')
        result.must_be_instance_of Array
        result.wont_be :empty?
        result.each do |r|
          r.size.must_equal 2
          r[0].must_be_instance_of String
          r[0].upcase.must_include 'THRONES'
          r[1].must_be_instance_of String
          r[1].must_include 'magnet:'
        end
      end
    end
  end

  it "raises an error if the instance doesn't implement get_links" do
    -> { DownloadTV::LinkGrabber.new('').get_links('test') }.must_raise NotImplementedError
  end
end
