# frozen_string_literal: true

describe DownloadTV::ThePirateBayAPI do
  let(:grabber) { described_class.new }
  let(:fake_agent) { instance_spy(Mechanize) }

  before do
    allow(grabber).to receive_messages(online?: true, agent: fake_agent)
  end

  it 'has a url attribute on creation' do
    expect(grabber.url).not_to be_nil
  end

  it "raises NoTorrentsError when torrent can't be found" do
    fake_response = instance_spy(Mechanize::Page, body: '[{"name":"No results returned"}]')
    allow(fake_agent).to receive(:get).and_return(fake_response)
    expect { grabber.get_links('Fake Show') }.to raise_error(DownloadTV::NoTorrentsError)
  end

  context 'when results are found' do
    let(:fake_response) { instance_spy(Mechanize::Page, body: '[{"name":"The.Boys.S02E01","info_hash":"abc123"}]') }

    before do
      allow(fake_agent).to receive(:get).and_return(fake_response)
    end

    it 'returns an array' do
      expect(grabber.get_links('The Boys S02E01')).to be_an_instance_of(Array)
    end

    it 'returns non-empty results' do
      expect(grabber.get_links('The Boys S02E01')).not_to be_empty
    end

    it 'returns results containing boys in name' do
      expect(grabber.get_links('The Boys S02E01').first[0].upcase).to include('BOYS')
    end

    it 'returns results with magnet link' do
      expect(grabber.get_links('The Boys S02E01').first[1]).to include('magnet:')
    end
  end
end
