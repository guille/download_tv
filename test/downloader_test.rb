# frozen_string_literal: true

require 'test_helper'

describe DownloadTV::Downloader do
  config_path = File.realdirpath("#{__dir__}/test_config")

  before do
    Dir.chdir(__dir__)
    create_dummy_config(config_path) unless File.exist?(config_path)
  end

  after do
    File.delete(config_path) if File.exist?(config_path)
  end

  describe 'when creating the object' do
    it 'can receive an optional configuration hash' do
      dl = DownloadTV::Downloader.new(auto: true, grabber: 'KAT', path: config_path)
      _(dl.config.content[:auto]).must_equal true
      _(dl.config.content[:grabber]).must_equal 'KAT'
    end
  end

  describe 'the fix_names method' do
    it 'should remove apostrophes, colons and parens' do
      shows = ['Mr. Foo S01E02', 'Bar (UK) S00E22', "Let's S05E03",
               'Baz: The Story S05E22']
      result = ['Mr. Foo S01E02', 'Bar S00E22', 'Lets S05E03',
                'Baz The Story S05E22']

      dl = DownloadTV::Downloader.new(ignored: [], path: config_path)
      _(dl.fix_names(shows)).must_equal result
    end
  end

  describe 'the reject_ignored method' do
    it 'should remove ignored shows' do
      shows = ['Bar S00E22', 'Ignored S20E22']
      result = ['Bar S00E22']

      dl = DownloadTV::Downloader.new(ignored: ['ignored'], path: config_path)
      _(dl.reject_ignored(shows)).must_equal result
    end
  end

  describe 'the check_date method' do
    it 'exits the script when up to date' do
      dl = DownloadTV::Downloader.new(date: Date.today, path: config_path)
      _(dl.check_date(0)).must_be_nil
    end

    it 'uses the offset to adjust the date' do
      # Would exit with offset 0
      dl = DownloadTV::Downloader.new(date: Date.today, path: config_path)

      date = dl.check_date(1)

      _(date).must_equal(Date.today - 1)
      _(dl.config.content[:date]).must_equal Date.today
    end
  end

  describe 'the filter_shows method' do
    it 'removes names with exclude words in them' do
      f = {:excludes => ["2160P"], :includes => []}
      dl = DownloadTV::Downloader.new(path: config_path, filters: f)
      links = [['Link 1', ''], ['Link 2 2160p', ''], ['Link 3', '']]
      res = [['Link 1', ''], ['Link 3', '']]
      _(dl.filter_shows(links)).must_equal res
    end

    it 'removes names without include words in them' do
      f = {:excludes => [], :includes => %w[REPACK]}
      dl = DownloadTV::Downloader.new(path: config_path, filters: f)
      links = [['Link 1', ''], ['Link 2 2160p', ''], ['Link 3', ''],
               ['Link REPACK 5', '']]
      res = [['Link REPACK 5', '']]
      _(dl.filter_shows(links)).must_equal res
    end

    it "doesn't apply a filter if it would reject every option" do
      f = {:excludes => %w[2160P 720P], :includes => []}
      dl = DownloadTV::Downloader.new(path: config_path, filters: f)
      links = [['Link 1 720p', ''], ['Link 2 2160p', ''], ['Link 720p 3', '']]
      res = [['Link 1 720p', ''], ['Link 720p 3', '']]
      _(dl.filter_shows(links)).must_equal res
    end
  end

  describe 'the get_link method' do
    it "returns an empty string when it can't find links" do
      t = Minitest::Mock.new
      show = 'Example Show S01E01'

      t.expect(:get_links, [], [show])
      dl = DownloadTV::Downloader.new(auto: true, path: config_path, pending: ['show 11'])
      _(dl.get_link(t, show, true)).must_equal ''
      _(dl.config.content[:pending]).must_equal ['show 11', show]

      t.expect(:get_links, [], [show])
      dl = DownloadTV::Downloader.new(auto: false, path: config_path, pending: [])
      _(dl.get_link(t, show, true)).must_equal ''
      _(dl.config.content[:pending]).must_include show

      t.verify
    end

    it 'returns the first link when auto is set to true' do
      t = Minitest::Mock.new
      show = 'Example Show S01E01'

      t.expect(:get_links, [['Name 1', 'Link 1'], ['Name 2', 'Link 2']], [show])
      dl = DownloadTV::Downloader.new(auto: true, path: config_path)
      _(dl.get_link(t, show)).must_equal 'Link 1'
      t.verify
    end
  end

  describe 'the detect_os method' do
    it 'returns xdg open for linux' do
      prev = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = 'linux-gnu'

      dl = DownloadTV::Downloader.new(path: config_path)
      _(dl.detect_os).must_equal 'xdg-open'

      RbConfig::CONFIG['host_os'] = prev
    end

    it 'returns open for mac' do
      prev = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = 'darwin15.6.0'

      dl = DownloadTV::Downloader.new(path: config_path)
      _(dl.detect_os).must_equal 'open'

      RbConfig::CONFIG['host_os'] = prev
    end

    it "exits when it can't detect the platform" do
      prev = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = 'dummy'

      dl = DownloadTV::Downloader.new(path: config_path)

      to_run = -> { run_silently { _(dl.detect_os).must_equal 'xdg-open' } }
      _(to_run).must_raise SystemExit

      RbConfig::CONFIG['host_os'] = prev
    end
  end
end
