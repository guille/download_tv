# frozen_string_literal: true

describe DownloadTV::Torrent do
  let(:default_grabber) { nil }
  # let(:third_grabber) { double('eztv') }
  let(:second_grabber) { double('eztv') }
  let(:first_grabber) { double('tpb') }
  let(:test_show) { double('test_show') }
  subject { described_class.new(default_grabber) }

  before :each do
    allow(DownloadTV::ThePirateBay).to receive(:new).and_return first_grabber
    allow(DownloadTV::Eztv).to receive(:new).and_return second_grabber
    # allow(DownloadTV::TorrentGalaxy).to receive(:new).and_return third_grabber

    allow(first_grabber).to receive(:online?).and_return(true)
    allow(second_grabber).to receive(:online?).and_return(true)
    # allow(third_grabber).to receive(:online?).and_return(true)
  end

  describe 'Torrent.grabbers' do
    it 'returns the list of grabbers' do
      # This order is assumed in the other specs, so explicitly checking it here
      expect(described_class.grabbers).to eq %w[ThePirateBay Eztv]
    end
  end

  describe '#get_links' do
    it 'will use the first grabber and return its #get_link result' do
      result = double('result')
      expect(first_grabber).to receive(:get_links).with(test_show).and_return(result)

      subject.get_links(test_show)
    end

    context 'when the first grabber is offline' do
      before do
        allow(first_grabber).to receive(:online?).and_return(false)
      end

      it 'will use the second grabber' do
        expect(first_grabber).not_to receive(:get_links)
        expect(second_grabber).to receive(:get_links).with(test_show)
        # expect(third_grabber).not_to receive(:get_links)
        # Add other torrents here with expectation #not_to receive

        subject.get_links(test_show)
      end
    end

    context 'when all the grabbers are offline' do
      before do
        allow(first_grabber).to receive(:online?).and_return(false)
        allow(second_grabber).to receive(:online?).and_return(false)
        # allow(third_grabber).to receive(:online?).and_return(false)
      end

      it 'will exit' do
        expect(first_grabber).not_to receive(:get_links)
        expect(second_grabber).not_to receive(:get_links)
        # expect(third_grabber).not_to receive(:get_links)

        expect { subject.get_links(test_show) }.to raise_error(SystemExit)
      end
    end

    context 'when one grabber does not find a link' do
      before do
        allow(first_grabber).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
      end

      it 'will keep trying until one does' do
        expect(first_grabber).to receive(:get_links).ordered
        expect(second_grabber).to receive(:get_links).ordered

        subject.get_links(test_show)
      end
    end

    context 'when no grabber can find a link' do
      before do
        allow(first_grabber).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
        allow(second_grabber).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
        # allow(third_grabber).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
      end

      it 'will return an empty array' do
        expect(first_grabber).to receive(:get_links).ordered
        expect(second_grabber).to receive(:get_links).ordered
        # expect(third_grabber).to receive(:get_links).ordered

        expect(subject.get_links(test_show)).to eq []
      end
    end

    context 'when the default grabber is set' do
      let(:default_grabber) { 'Eztv' }

      it 'will use that grabber preferently' do
        test_show = double('test_show')
        expect(first_grabber).not_to receive(:get_links)
        expect(second_grabber).to receive(:get_links)
        # expect(third_grabber).to receive(:get_links).with(test_show)

        subject.get_links(test_show)
      end
    end

    context 'when a grabber fails on a run and it is called twice' do
      before do
        count = 0
        allow(first_grabber).to receive(:get_links).exactly(2).times.with(test_show) do
          count += 1
          raise DownloadTV::NoTorrentsError if count == 1
        end
      end

      it 'the second run will use the original order' do
        expect(first_grabber).to receive(:get_links).exactly(2).times
        expect(second_grabber).to receive(:get_links).exactly(1).time
        # expect(third_grabber).not_to receive(:get_links)

        subject.get_links(test_show)
        subject.get_links(test_show)
      end
    end
  end
end
