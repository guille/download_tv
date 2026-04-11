# frozen_string_literal: true

describe DownloadTV::Downloader do
  subject(:downloader) { described_class.new(opts) }

  let(:opts) { { path: '/tmp/test_config' } }

  before do
    allow(File).to receive_messages(exist?: true, read: '{}')
    allow(JSON).to receive(:parse).and_return({ version: DownloadTV::VERSION, pending: [] })
    allow(FileUtils).to receive(:rm_f)
  end

  describe 'when creating the object' do
    it 'can receive an optional configuration hash' do
      dl = described_class.new(auto: true, grabber: 'KAT', path: '/tmp/test')
      expect(dl.config[:auto]).to be true
      expect(dl.config[:grabber]).to eq 'KAT'
    end
  end

  describe '#fix_names' do
    it 'removes apostrophes, colons and parens' do
      shows = ['Mr. Foo S01E02', 'Bar (UK) S00E22', "Let's S05E03",
               'Baz: The Story S05E22']
      result = ['Mr. Foo S01E02', 'Bar S00E22', 'Lets S05E03',
                'Baz The Story S05E22']

      dl = described_class.new(ignored: [], path: '/tmp/test')
      expect(dl.fix_names(shows)).to eq result
    end
  end

  describe '#reject_ignored' do
    it 'removes ignored shows' do
      shows = ['Bar S00E22', 'Ignored S20E22']
      result = ['Bar S00E22']

      dl = described_class.new(ignored: ['ignored'], path: '/tmp/test')
      expect(dl.reject_ignored(shows)).to eq result
    end
  end

  describe '#date_to_check_from' do
    it 'returns the config date when offset is not given' do
      dl = described_class.new(date: Date.today, path: '/tmp/test')
      expect(dl.date_to_check_from(0)).to eq Date.today
    end

    it 'uses the offset to adjust the date' do
      dl = described_class.new(date: Date.today, path: '/tmp/test')

      date = dl.date_to_check_from(1)

      expect(date).to eq(Date.today - 1)
      expect(dl.config[:date]).to eq Date.today
    end
  end

  describe '#filter_shows' do
    it 'removes names with exclude words in them' do
      f = { excludes: ['2160P'], includes: [] }
      dl = described_class.new(path: '/tmp/test', filters: f)
      links = [['Link 1', ''], ['Link 2 2160p', ''], ['Link 3', '']]
      res = [['Link 1', ''], ['Link 3', '']]
      expect(dl.filter_shows(links)).to eq res
    end

    it 'removes names without include words in them' do
      f = { excludes: [], includes: ['REPACK'] }
      dl = described_class.new(path: '/tmp/test', filters: f)
      links = [['Link 1', ''], ['Link 2 2160p', ''], ['Link 3', ''],
               ['Link REPACK 5', '']]
      res = [['Link REPACK 5', '']]
      expect(dl.filter_shows(links)).to eq res
    end

    it "doesn't apply a filter if it would reject every option" do
      f = { excludes: %w[2160P 720P], includes: [] }
      dl = described_class.new(path: '/tmp/test', filters: f)
      links = [['Link 1 720p', ''], ['Link 2 2160p', ''], ['Link 720p 3', '']]
      res = [['Link 1 720p', ''], ['Link 720p 3', '']]
      expect(dl.filter_shows(links)).to eq res
    end
  end

  describe '#get_link' do
    it "returns nil when it can't find links" do
      torrent = instance_double(DownloadTV::Torrent)
      allow(torrent).to receive(:get_links).with('Example Show S01E01').and_return([])
      dl = described_class.new(auto: true, path: '/tmp/test', pending: ['show 11'])
      expect(dl.get_link(torrent, 'Example Show S01E01', save_pending: true)).to be_nil
      expect(dl.config[:pending]).to include('show 11', 'Example Show S01E01')

      allow(torrent).to receive(:get_links).with('Example Show S01E01').and_return([])
      dl = described_class.new(auto: false, path: '/tmp/test', pending: [])
      expect(dl.get_link(torrent, 'Example Show S01E01', save_pending: true)).to be_nil
      expect(dl.config[:pending]).to include('Example Show S01E01')
    end

    it 'returns the first link when auto is set to true' do
      torrent = instance_double(DownloadTV::Torrent)
      allow(torrent).to receive(:get_links).with('Example Show S01E01')
                                           .and_return([['Name 1', 'Link 1'], ['Name 2', 'Link 2']])
      dl = described_class.new(auto: true, path: '/tmp/test')
      expect(dl.get_link(torrent, 'Example Show S01E01')).to eq 'Link 1'
    end
  end

  describe '#detect_os' do
    it 'returns xdg open for linux' do
      stub_const('RbConfig::CONFIG', RbConfig::CONFIG.merge('host_os' => 'linux-gnu'))

      dl = described_class.new(path: '/tmp/test')
      expect(dl.detect_os).to eq 'xdg-open'
    end

    it 'returns open for mac' do
      stub_const('RbConfig::CONFIG', RbConfig::CONFIG.merge('host_os' => 'darwin15.6.0'))

      dl = described_class.new(path: '/tmp/test')
      expect(dl.detect_os).to eq 'open'
    end

    it "exits when it can't detect the platform" do
      stub_const('RbConfig::CONFIG', RbConfig::CONFIG.merge('host_os' => 'dummy'))

      dl = described_class.new(path: '/tmp/test')
      expect { dl.detect_os }.to raise_error(SystemExit)
    end
  end
end
