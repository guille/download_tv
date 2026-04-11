# frozen_string_literal: true

describe DownloadTV::Eztv do
  let(:grabber) { described_class.new }
  let(:fake_agent) { instance_spy(Mechanize) }

  before do
    allow(grabber).to receive_messages(online?: true, agent: fake_agent)
  end

  it 'has a url attribute on creation' do
    expect(grabber.url).not_to be_nil
  end

  it "raises NoTorrentsError when torrent can't be found" do
    fake_page = build_fake_page_with_empty_results
    allow(fake_agent).to receive(:get).and_return(fake_page)
    expect { grabber.get_links('Fake Show') }.to raise_error(DownloadTV::NoTorrentsError)
  end

  def build_fake_page_with_empty_results
    fake_page = instance_spy(Mechanize::Page)
    fake_form = instance_spy(Mechanize::Form)
    allow(fake_page).to receive_messages(forms: [fake_form], search: [])
    allow(fake_form).to receive(:submit).and_return(fake_page)
    fake_page
  end

  context 'when results are found' do
    let(:fake_page) { instance_spy(Mechanize::Page) }
    let(:fake_form) { instance_spy(Mechanize::Form) }
    let(:fake_magnet) { instance_spy(Nokogiri::XML::Element) }

    before do
      fake_title_attr = instance_spy(Nokogiri::XML::Attr, text: 'The Boys S02E01 Magnet')
      fake_href_attr = instance_spy(Nokogiri::XML::Attr, text: 'magnet:?xt=urn:btih:abc123')
      allow(fake_page).to receive_messages(forms: [fake_form], search: [])
      allow(fake_page).to receive(:search).with('a.magnet').and_return([fake_magnet])
      allow(fake_magnet).to receive(:attribute).with('title').and_return(fake_title_attr)
      allow(fake_magnet).to receive(:attribute).with('href').and_return(fake_href_attr)
      allow(fake_form).to receive(:submit).and_return(fake_page)
      allow(fake_agent).to receive(:get).and_return(fake_page)
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
