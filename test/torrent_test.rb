require 'test_helper'

describe DownloadTV::Torrent do
  describe 'when creating the object' do
    before do
      @t = DownloadTV::Torrent.new
    end

    it 'will have the right amount of grabbers' do
      @t.g_names.size.must_equal @t.grabbers.size - 1
      @t.g_instances.size.must_equal 1
    end

    it 'will populate the instances' do
      @t.grabbers.size.times.each { @t.change_grabbers }
      @t.g_names.empty?.must_equal true
      @t.g_instances.size.must_equal @t.grabbers.size
    end

    it 'will start with all tries available' do
      @t.tries.must_equal @t.grabbers.size - 1
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
      t.g_instances.first.class.name.must_equal 'DownloadTV::TorrentAPI'
    end

    %w[Eztv KAT ThePirateBay TorrentAPI].each do |g|
      it 'correctly uses the given grabber first' do
        t = DownloadTV::Torrent.new(g)
        t.g_instances.first.class.name.must_equal "DownloadTV::#{g}"
      end
    end
  end
end
