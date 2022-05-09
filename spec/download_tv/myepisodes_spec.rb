# frozen_string_literal: true

describe DownloadTV::MyEpisodes do
  let(:save_cookie) { true }
  let(:page) { double('page') }
  let(:agent) { double('agent', :user_agent= => nil, get: page) }
  let(:cookie_jar) { double('cookie_jar') }
  subject { described_class.new('user', true) }

  before :each do
    allow(Mechanize).to receive(:new).and_return agent
    allow(agent).to receive(:cookie_jar).and_return cookie_jar
    allow(cookie_jar).to receive(:load)
    allow(cookie_jar).to receive(:save)
  end

  describe '#initialize' do
    context 'when cookie does not load' do
      it 'will execute a user/password login' do
        allow_any_instance_of(described_class).to receive(:load_cookie).and_return false
        expect_any_instance_of(described_class).to receive(:manual_login).once.and_return nil
        subject
      end
    end

    context 'when using a valid cookie' do
      it 'will log in via cookie' do
        allow_any_instance_of(described_class).to receive(:load_cookie).and_return true
        expect_any_instance_of(described_class).not_to receive(:manual_login)
        subject
      end
    end
  end

  describe '#get_shows_since' do
    # TODO
  end
end
