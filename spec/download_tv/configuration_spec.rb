# frozen_string_literal: true

describe DownloadTV::Configuration do
  let(:raw_config) { double('raw_config') }
  let(:parsed_config) { { version: DownloadTV::VERSION, pending: [] } }
  let(:opts) { {} }
  subject { described_class.new(opts) }

  before :each do
    allow(File).to receive(:exist?).and_return true
    allow(File).to receive(:read).and_return raw_config
    allow(JSON).to receive(:parse).and_return parsed_config
  end

  describe '#[] and #[]=' do
    it 'will set and get values of the underlying hash' do
      subject[:test] = :any
      expect(subject[:test]).to eq(:any)
    end
  end

  describe '#initialize' do
    context 'when the config file exists' do
      context 'when options are given' do
        let(:opts) { { myepisodes_user: 'test', pending: [1], ignored: ['aAAa'] } }
        it 'will apply them to the final config' do
          expect(subject[:myepisodes_user]).to eq opts[:myepisodes_user]
          expect(subject[:pending]).to eq opts[:pending]
        end

        it 'will downcase strings in :ignored' do
          expect(subject[:ignored].first).to eq opts[:ignored].first.downcase
        end
      end
    end

    context 'when the config file does not exist' do
      before :each do
        allow(File).to receive(:exist?).and_return false
        allow(FileUtils).to receive(:mkdir_p)
        allow_any_instance_of(described_class).to receive(:change_configuration)
        allow_any_instance_of(described_class).to receive(:serialize)
      end

      context 'when options are given' do
        let(:opts) { { myepisodes_user: 'test' } }

        it 'will override the other values' do
          expect(subject[:myepisodes_user]).to eq opts[:myepisodes_user]
        end
      end
    end
  end

  describe '#change_configuration' do
    let(:myepisodes_user) { 'myep' }
    let(:cookies) { 'n' }
    let(:ignored) { 'ignored1,ignored2' }

    before :each do
      allow(File).to receive(:exist?).and_return false
      allow(FileUtils).to receive(:mkdir_p)
      allow_any_instance_of(described_class).to receive(:serialize)
      allow($stdin).to receive(:gets).and_return(myepisodes_user, cookies, ignored, '', '')
    end

    it 'will create a new config with the given and the default values' do
      expect(subject[:myepisodes_user]).to eq myepisodes_user
      expect(subject[:cookie]).to be false
      expect(subject[:auto]).to be true
      expect(subject[:ignored].size).to eq 2
      expect(subject[:date]).to eq(Date.today - 1)
      expect(subject[:filters]).not_to be_nil
      expect(subject[:version]).not_to be_nil
      expect(subject[:pending]).not_to be_nil
      expect(subject[:grabber]).not_to be_nil
    end
  end

  describe '#serialize' do
    let(:parsed_config) { { version: DownloadTV::VERSION, pending: [1, 1, 2] } }

    before :each do
      allow(File).to receive(:write).and_return nil
    end

    it 'will remove duplicates from :pending' do
      subject.serialize
      expect(subject[:pending].size).to eq 2
    end

    it 'will write to a file' do
      expect(File).to receive(:write)
      subject.serialize
    end

    context 'when a path is given in the options' do
      let(:opts) { { path: '/tmp/test' } }
      it 'will write to a file in our given path' do
        config = double('config')
        expect(JSON).to receive(:generate).and_return(config)
        expect(File).to receive(:write).with(opts[:path], config)
        subject.serialize
      end
    end
  end

  describe '#to_s' do
    it 'will form a string with each (key, value) pair in a new line' do
      expected = "version: #{DownloadTV::VERSION}\n"\
        "pending: []\n"
      expect(subject.to_s).to eq expected
    end
  end

  describe '#clear_pending' do
    it 'will clear :pending and call serialize' do
      subject[:pending] << double
      expect(subject).to receive(:serialize)
      expect(subject[:pending].size).to eq 1
      subject.clear_pending
      expect(subject[:pending].size).to eq 0
    end
  end

  describe '#queue_pending' do
    it 'will add an item to :pending and serialize' do
      expect(subject).to receive(:serialize)
      expect(subject[:pending].size).to eq 0
      subject.queue_pending(double)
      expect(subject[:pending].size).to eq 1
    end
  end

  context 'breaking changes:' do
    let(:version) { nil }
    let(:parsed_config) do
      {
        version: version
      }
    end

    before :each do
      stub_const('DownloadTV::VERSION', '2.1.10')
      allow(File).to receive(:exist?).and_return true
      allow(File).to receive(:read).and_return raw_config
      allow(JSON).to receive(:parse).and_return parsed_config
    end

    describe 'when the config does not have a version' do
      it 'will trigger a config update' do
        expect_any_instance_of(described_class).to receive(:change_configuration).once.and_return nil
        subject
      end
    end

    describe 'when the app version is newer (patch)' do
      let(:version) { '2.1.9' }
      it 'will NOT trigger a config update' do
        expect_any_instance_of(described_class).not_to receive(:change_configuration)
        subject
      end
    end

    describe 'when the app version is the same' do
      let(:version) { '2.1.10' }
      it 'will NOT trigger a config update' do
        expect_any_instance_of(described_class).not_to receive(:change_configuration)
        subject
      end
    end

    describe 'when the app version is newer (minor)' do
      let(:version) { '2.0.19' }

      it 'will trigger a config update' do
        expect_any_instance_of(described_class).to receive(:change_configuration).once.and_return nil
        subject
      end
    end

    describe 'when the app version is newer (major)' do
      let(:version) { '1.20.999' }

      it 'will trigger a config update' do
        expect_any_instance_of(described_class).to receive(:change_configuration).once.and_return nil
        subject
      end
    end

    describe 'when the app version is older (any)' do
      let(:version) { '2.1.11' }
      it 'will trigger a config update' do
        expect_any_instance_of(described_class).to receive(:change_configuration).once.and_return nil
        subject
      end
    end
  end
end
