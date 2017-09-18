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
    it 'should store the first argument as @offset' do
      DownloadTV::Downloader.new(3, path: config_path).offset.must_equal 3
      DownloadTV::Downloader.new(-3, path: config_path).offset.must_equal 3
    end

    it 'should receive an integer for the offset' do
      -> { DownloadTV::Downloader.new('foo') }.must_raise NoMethodError
    end

    it 'can receive an optional configuration hash' do
      dl = DownloadTV::Downloader.new(0, auto: true, grabber: 'KAT', path: config_path)
      dl.config.content[:auto].must_equal true
      dl.config.content[:grabber].must_equal 'KAT'
    end
  end

  describe 'the fix_names method' do
    it 'should remove apostrophes, colons and parens' do
      shows = ['Mr. Foo S01E02', 'Bar (UK) S00E22', "Let's S05E03", 'Baz: The Story S05E22']
      result = ['Mr. Foo S01E02', 'Bar S00E22', 'Lets S05E03', 'Baz The Story S05E22']

      dl = DownloadTV::Downloader.new(0, ignored: [], path: config_path)
      dl.fix_names(shows).must_equal result
    end

    it 'should remove ignored shows' do
      shows = ['Mr. Foo S01E02', 'Bar (UK) S00E22', 'Ignored S20E22', "Let's S05E03"]
      result = ['Mr. Foo S01E02', 'Bar S00E22', 'Lets S05E03']

      dl = DownloadTV::Downloader.new(0, ignored: ['ignored'], path: config_path)
      dl.fix_names(shows).must_equal result
    end
  end

  describe 'the check_date method' do
    it 'exits the script when up to date' do
      dl = DownloadTV::Downloader.new(0, date: Date.today, path: config_path)
      to_run = -> { run_silently { dl.check_date } }
      to_run.must_raise SystemExit
    end

    it 'uses the offset to adjust the date' do
      # Would exit with offset 0
      dl = DownloadTV::Downloader.new(1, date: Date.today, path: config_path)

      date = dl.check_date

      date.must_equal(Date.today - 1)
      dl.config.content[:date].must_equal Date.today
    end
  end

  describe 'the filter_shows method' do
    it 'removes names with 2160p in them' do
      dl = DownloadTV::Downloader.new(0, path: config_path)
      links = [['Link 1', ''], ['Link 2 2160p', ''], ['Link 3', '']]
      res = [['Link 1', ''], ['Link 3', '']]
      dl.filter_shows(links).must_equal res
    end

    it 'removes names with 1080p in them' do
      dl = DownloadTV::Downloader.new(0, path: config_path)
      links = [['Link.1080p', ''], ['Link 2 2160p', ''], ['Link 3', '']]
      res = [['Link 3', '']]
      dl.filter_shows(links).must_equal res
    end

    it 'removes names with 720p in them' do
      dl = DownloadTV::Downloader.new(0, path: config_path)
      links = [['Link 1', ''], ['Link 2 720p', ''], ['Link.720p.rip', '']]
      res = [['Link 1', '']]
      dl.filter_shows(links).must_equal res
    end

    it 'removes names with WEB in them' do
      dl = DownloadTV::Downloader.new(0, path: config_path)
      links = [['Link 1 WEBRIP', ''], ['Link 2 rip', ''], ['Link.720p.rip', '']]
      res = [['Link 2 rip', '']]
      dl.filter_shows(links).must_equal res
    end

    it 'removes names without PROPER or REPACK in them' do
      dl = DownloadTV::Downloader.new(0, path: config_path)
      links = [['Link 1', ''], ['Link 2 2160p', ''], ['Link 3', ''], ['Link 4 PROPER', ''], ['Link REPACK 5', '']]
      res = [['Link 4 PROPER', ''], ['Link REPACK 5', '']]
      dl.filter_shows(links).must_equal res
    end

    it "doesn't apply a filter if it would reject every option" do
      dl = DownloadTV::Downloader.new(0, path: config_path)
      links = [['Link 1 720p', ''], ['Link 2 2160p', ''], ['Link 720p 3', '']]
      res = [['Link 1 720p', ''], ['Link 720p 3', '']]
      dl.filter_shows(links).must_equal res
    end
  end

  describe 'the get_link method' do
    it "returns an empty string when it can't find links" do
      t = Minitest::Mock.new
      show = 'Example Show S01E01'

      t.expect(:get_links, [], [show])
      dl = DownloadTV::Downloader.new(0, auto: true, path: config_path)
      dl.get_link(t, show).must_equal ''
      t.expect(:get_links, [], [show])
      dl = DownloadTV::Downloader.new(0, auto: false, path: config_path)
      dl.get_link(t, show).must_equal ''
    end

    it 'returns the first link when auto is set to true' do
      t = Minitest::Mock.new
      show = 'Example Show S01E01'

      t.expect(:get_links, [['Name 1', 'Link 1'], ['Name 2', 'Link 2']], [show])
      dl = DownloadTV::Downloader.new(0, auto: true, path: config_path)
      dl.get_link(t, show).must_equal 'Link 1'
    end
  end

  describe 'the detect_os method' do
    it 'returns xdg open for linux' do
      prev = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = 'linux-gnu'

      dl = DownloadTV::Downloader.new(0, path: config_path)
      dl.detect_os.must_equal 'xdg-open'

      RbConfig::CONFIG['host_os'] = prev
    end

    it 'returns open for mac' do
      prev = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = 'darwin15.6.0'

      dl = DownloadTV::Downloader.new(0, path: config_path)
      dl.detect_os.must_equal 'open'

      RbConfig::CONFIG['host_os'] = prev
    end

    it "exits when it can't detect the platform" do
      prev = RbConfig::CONFIG['host_os']
      RbConfig::CONFIG['host_os'] = 'dummy'

      dl = DownloadTV::Downloader.new(0, path: config_path)

      to_run = -> { run_silently { dl.detect_os.must_equal 'xdg-open' } }
      to_run.must_raise SystemExit

      RbConfig::CONFIG['host_os'] = prev
    end
  end
end
