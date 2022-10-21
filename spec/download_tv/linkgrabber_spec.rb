# frozen_string_literal: true

describe DownloadTV::LinkGrabber do
  # TODO: Write specs for the individual grabbers (see #4)
  # grabbers = DownloadTV::Torrent.grabbers
  # instances = grabbers.map { |g| (DownloadTV.const_get g).new }

  # instances.each do |grabber|
  #   describe grabber do
  #   end
  # end

  it "raises an error if the instance doesn't implement get_links" do
    expect { DownloadTV::LinkGrabber.new(double).get_links(double) }.to raise_error(NotImplementedError)
  end
end
