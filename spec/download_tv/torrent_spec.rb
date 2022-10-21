# frozen_string_literal: true

describe DownloadTV::Torrent do
  let(:default_grabber) { nil }
  let(:eztv_mock) { double('eztv') }
  let(:torrentapi_mock) { double('torrentapi') }
  let(:torrentz_mock) { double('torrentz') }
  let(:tpb_mock) { double('tpb') }
  let(:test_show) { double('test_show') }
  subject { described_class.new(default_grabber) }

  before :each do
    allow(DownloadTV::TorrentAPI).to receive(:new).and_return torrentapi_mock
    allow(DownloadTV::Torrentz).to receive(:new).and_return torrentz_mock
    allow(DownloadTV::Eztv).to receive(:new).and_return eztv_mock
    # allow(DownloadTV::ThePirateBay).to receive(:new).and_return tpb_mock

    allow(torrentapi_mock).to receive(:online?).and_return(true)
    allow(torrentz_mock).to receive(:online?).and_return(true)
    allow(eztv_mock).to receive(:online?).and_return(true)
  end

  describe 'Torrent.grabbers' do
    it 'returns the list of grabbers' do
      # This order is assumed in the other specs, so explicitly checking it here
      expect(described_class.grabbers).to eq %w[TorrentAPI Torrentz Eztv]

    end
  end

  describe '#get_links' do
    it 'will use the first grabber and return its #get_link result' do
      result = double('result')
      expect(torrentapi_mock).to receive(:get_links).with(test_show).and_return(result)

      result = subject.get_links(test_show)
    end

    context 'when the first grabber is offline' do
      before do
        allow(torrentapi_mock).to receive(:online?).and_return(false)
      end

      it 'will use the second grabber' do
        expect(torrentapi_mock).not_to receive(:get_links)
        expect(eztv_mock).not_to receive(:get_links)
        expect(torrentz_mock).to receive(:get_links).with(test_show)

        result = subject.get_links(test_show)
      end
    end

    context 'when all the grabbers are offline' do
      before do
        allow(torrentapi_mock).to receive(:online?).and_return(false)
        allow(torrentz_mock).to receive(:online?).and_return(false)
        allow(eztv_mock).to receive(:online?).and_return(false)
      end

      it 'will exit' do
        expect(torrentapi_mock).not_to receive(:get_links)
        expect(torrentz_mock).not_to receive(:get_links)
        expect(eztv_mock).not_to receive(:get_links)

        expect { subject.get_links(test_show) }.to raise_error(SystemExit)
      end
    end

    context 'when one grabber does not find a link' do
      before do
        allow(torrentapi_mock).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
        allow(torrentz_mock).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
      end

      it 'will keep trying until one does' do
        expect(torrentapi_mock).to receive(:get_links).ordered
        expect(torrentz_mock).to receive(:get_links).ordered
        expect(eztv_mock).to receive(:get_links).ordered

        result = subject.get_links(test_show)
      end
    end

    context 'when no grabber can find a link' do
      before do
        allow(torrentapi_mock).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
        allow(torrentz_mock).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
        allow(eztv_mock).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
      end

      it 'will return an empty array' do
        expect(torrentapi_mock).to receive(:get_links).ordered
        expect(torrentz_mock).to receive(:get_links).ordered
        expect(eztv_mock).to receive(:get_links).ordered

        expect(subject.get_links(test_show)).to eq []
      end
    end

    context 'when the default grabber is set' do
      let(:default_grabber) { 'Eztv' }

      it 'will use that grabber preferently' do
        test_show = double('test_show')
        expect(torrentapi_mock).not_to receive(:get_links)
        expect(torrentz_mock).not_to receive(:get_links)
        expect(eztv_mock).to receive(:get_links).with(test_show)

        result = subject.get_links(test_show)
      end
    end

    context 'when a grabber fails on a run and it is called twice' do
      before do
        count = 0
        allow(torrentapi_mock).to receive(:get_links).exactly(2).times.with(test_show) do
          count += 1
          raise DownloadTV::NoTorrentsError if count == 1
        end

      end

      it 'the second run will use the original order' do
        expect(torrentapi_mock).to receive(:get_links).exactly(2).times
        expect(torrentz_mock).to receive(:get_links).exactly(1).time

        result = subject.get_links(test_show)
        result = subject.get_links(test_show)
      end
    end
  end
end
