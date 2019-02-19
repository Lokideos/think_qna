# frozen_string_literal: true

require 'rails_helper'

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
  end
end
