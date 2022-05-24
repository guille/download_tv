# frozen_string_literal: true

describe DownloadTV::Filterer do
  let(:excludes) { [] }
  let(:includes) { [] }
  let(:filters_config) { { excludes: excludes, includes: includes } }

  subject { described_class.new(filters_config) }

  describe '#filter' do
    let(:test_data) do
      [
        'Test 12',
        'Test 10',
        'Exclude'
      ]
    end

    context 'when there are no filters' do
      it 'will return the given list' do
        expect(subject.filter(test_data)).to eq test_data
      end
    end

    context 'when there are exclude filters' do
      describe 'when there is only one entry not matching (one filter)' do
        let(:excludes) { ['TEST'] }
        it 'will return it' do
          filtered = subject.filter(test_data)
          expect(filtered.size).to eq 1
          expect(filtered.first).to eq 'Exclude'
        end
      end

      describe 'when there is only one entry not matching (multiple filter)' do
        let(:excludes) { ['2', '0'] }
        it 'will return it' do
          filtered = subject.filter(test_data)
          expect(filtered.size).to eq 1
          expect(filtered.first).to eq 'Exclude'
        end
      end

      describe 'when only one filter matches' do
        let(:excludes) { ['0'] }
        it 'will not return that element' do
          filtered = subject.filter(test_data)
          expect(filtered.size).to eq 2
          expect(filtered.include?('Test 10')).to be false
        end
      end

      describe 'when no entries match' do
        let(:excludes) { ['zzzz'] }
        it 'will return the original' do
          filtered = subject.filter(test_data)
          expect(filtered).to eq test_data
        end
      end

      describe 'when all entries match (one filter)' do
        let(:excludes) { ['E'] }
        it 'will return the original' do
          filtered = subject.filter(test_data)
          expect(filtered).to eq test_data
        end
      end

      describe 'when all entries match (more filters)' do
        let(:excludes) { ['TEST', 'EXCLUDE'] }
        it 'will only apply filters until there would be no values left' do
          filtered = subject.filter(test_data)
          expect(filtered.size).to eq 1
          expect(filtered.first).to eq 'Exclude'
        end
      end
    end

    context 'when there are include filters' do
      let(:includes) { ['TEST'] }
      it 'will filter out entries not matching' do
        filtered = subject.filter(test_data)
        expect(filtered.size).to eq 2
        expect(filtered.include?('Exclude')).to be false
      end
    end

    context 'when there are both types of filters' do
      let(:excludes) { ['EXCLUDE'] }
      let(:includes) { ['EXCLUDE'] }

      it 'will apply "includes" filters first' do
        filtered = subject.filter(test_data)
        expect(filtered.size).to eq 1
        expect(filtered.first).to eq 'Exclude'
      end

      describe 'if the filters are not capitalised' do
        let(:excludes) { ['exclude'] }
        let(:includes) { ['test'] }
        it 'will not apply the filter successfully' do
          expect(subject.filter(test_data)).to eq test_data
        end
      end
    end
  end
end
