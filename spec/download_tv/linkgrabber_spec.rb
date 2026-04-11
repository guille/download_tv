# frozen_string_literal: true

describe DownloadTV::LinkGrabber do
  describe '#online?' do
    it 'returns true when HEAD request succeeds' do
      grabber = described_class.new('http://example.com')
      fake_agent = instance_spy(Mechanize)
      allow(grabber).to receive(:agent).and_return(fake_agent)
      allow(fake_agent).to receive(:head).and_return(true)

      expect(grabber.online?).to be true
    end

    it 'returns false when HEAD request raises an error' do
      grabber = described_class.new('http://example.com')
      fake_agent = instance_spy(Mechanize)
      allow(grabber).to receive(:agent).and_return(fake_agent)
      allow(fake_agent).to receive(:head).and_raise(StandardError)

      expect(grabber.online?).to be false
    end

    it 'formats URL with test string if it contains %s' do
      grabber = described_class.new('http://example.com/%s/search')
      fake_agent = instance_spy(Mechanize)
      allow(grabber).to receive(:agent).and_return(fake_agent)
      allow(fake_agent).to receive(:head).with('http://example.com/test/search').and_return(true)

      expect(grabber.online?).to be true
    end

    it 'passes the formatted URL to head' do
      grabber = described_class.new('http://example.com/%s/search')
      fake_agent = instance_spy(Mechanize)
      allow(grabber).to receive(:agent).and_return(fake_agent)
      allow(fake_agent).to receive(:head).and_return(true)
      expect(grabber.online?).to be true
    end
  end

  it "raises an error if the instance doesn't implement get_links" do
    expect { described_class.new('http://example.com').get_links('test') }.to raise_error(NotImplementedError)
  end
end
