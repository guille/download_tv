# frozen_string_literal: true

describe DownloadTV::Torrent do
  subject { described_class.new(default_grabber) }

  let(:default_grabber) { nil }
  let(:first_grabber) { instance_double(DownloadTV::ThePirateBayAPI) }
  let(:test_show) { 'test_show' }

  before do
    allow(DownloadTV::ThePirateBayAPI).to receive(:new).and_return first_grabber
    allow(first_grabber).to receive(:online?).and_return(true)
    allow_any_instance_of(described_class).to receive(:warn)
    allow_any_instance_of(described_class).to receive(:puts)
  end

  describe 'Torrent.grabbers' do
    it 'returns the list of grabbers' do
      expect(described_class.grabbers).to eq %w[ThePirateBayAPI]
    end
  end

  describe '#get_links' do
    it 'uses the first grabber and returns its result' do
      result = []
      expect(first_grabber).to receive(:get_links).with(test_show).and_return(result)
      expect(subject.get_links(test_show)).to eq(result)
    end

    context 'when the grabber is offline' do
      before do
        allow(first_grabber).to receive(:online?).and_return(false)
      end

      it 'exits' do
        expect(first_grabber).not_to receive(:get_links)
        expect { subject.get_links(test_show) }.to raise_error(SystemExit)
      end
    end

    context 'when the grabber does not find a link' do
      before do
        allow(first_grabber).to receive(:get_links).with(test_show).and_raise(DownloadTV::NoTorrentsError)
      end

      it 'returns an empty array' do
        expect(first_grabber).to receive(:get_links).with(test_show)
        expect(subject.get_links(test_show)).to eq []
      end
    end

    context 'when the default grabber is set' do
      let(:default_grabber) { 'ThePirateBayAPI' }

      it 'uses that grabber' do
        expect(first_grabber).to receive(:get_links).with(test_show)
        subject.get_links(test_show)
      end
    end

    context 'when called multiple times' do
      it 'resets state between calls' do
        allow(first_grabber).to receive(:get_links).with(test_show).and_return([], [])
        subject.get_links(test_show)
        subject.get_links(test_show)
      end
    end
  end
end
