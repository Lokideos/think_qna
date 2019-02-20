# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Services::Search, type: :model do
  subject { Services::Search.new('query_string', 'Question') }

  it { should validate_presence_of :query }
  it { should validate_presence_of :search_type }
  it { should validate_inclusion_of(:search_type).in_array(Services::Search::SEARCH_TYPES) }

  describe '#call' do
    it 'should return search results' do
      allow(subject.search_type.constantize).to receive(:search).and_return('Search result')

      expect(subject.call).to eq 'Search result'
    end

    it 'should raise exception StandardError if search attributes is invalid' do
      service = Services::Search.new(nil, 'bad_type')

      expect { service.call }.to raise_error StandardError
    end

    it 'should call ThinikingSphinx search if search_type is Global' do
      service = Services::Search.new('query_string', 'Global')
      expect(ThinkingSphinx).to receive(:search)

      service.call
    end

    it 'should call .search on search_type if it is not Global' do
      Services::Search::SEARCH_TYPES.each do |search_type|
        next if search_type == 'Global'

        service = Services::Search.new('query_string', search_type)
        expect(search_type.constantize).to receive(:search)

        service.call
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
