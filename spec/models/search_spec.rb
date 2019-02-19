# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Search, type: :model do
  it { should validate_presence_of :query }
  it { should validate_presence_of :search_type }

  it 'should allow search only for search types in Search::SEARCH_TYPE' do
    bad_search_request = build(:search, search_type: 'bad_type')

    expect(bad_search_request).to_not be_valid
  end

  describe '#perform_search' do
    it 'should return search results' do
      search = create(:search)
      allow(search.search_type.constantize).to receive(:search).and_return('Search result')

      expect(search.perform_search).to eq 'Search result'
    end

    it 'should call ThinkingSphinx.search if search_type is Global' do
      search = create(:search, search_type: 'Global')
      expect(ThinkingSphinx).to receive(:search)

      search.perform_search
    end

    it 'should call .search on search_type if it is not Global' do
      Search::SEARCH_TYPES.each do |search_type|
        next if search_type == 'Global'

        search = create(:search, search_type: search_type)
        expect(search_type.constantize).to receive(:search)

        search.perform_search
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
