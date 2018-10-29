require 'test_helper'

describe DownloadTV::Torrent do
  grabber_names = DownloadTV::Torrent.new(nil).grabbers
  describe 'when creating the object' do
    before do
      @t = DownloadTV::Torrent.new
    end

    it 'will populate the instances' do
      @t.g_instances.size.must_equal grabber_names.size
    end

    it 'will start with all tries available' do
      @t.tries.must_equal grabber_names.size - 1
    end

    it 'will call get_links on its grabber' do
      @t.g_instances.first.stub :get_links, %w[test result] do
        @t.get_links('test show').must_equal %w[test result]
      end
    end
  end

  describe 'when giving it a default grabber' do
    it 'has a default order' do
      t = DownloadTV::Torrent.new(nil)
      expected = grabber_names.map { |i| "DownloadTV::#{i}" }
      t.g_instances.map { |i| i.class.name }.must_equal expected
    end

    grabber_names.each do |g|
      it 'correctly uses the given grabber first' do
        t = DownloadTV::Torrent.new(g)
        t.g_instances.first.class.name.must_equal "DownloadTV::#{g}"
      end
    end
  end
end
