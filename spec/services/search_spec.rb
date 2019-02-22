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

    it 'should call .search on Question/Answer/Comment and return matched results' do
      Services::Search::SEARCH_TYPES.each do |search_type|
        next if %w[Global User].include?(search_type)

        object1 = create(search_type.downcase.to_sym, body: "#{search_type.downcase.to_sym} 1")
        object2 = create(search_type.downcase.to_sym, body: "#{search_type.downcase.to_sym} 2")
        service = Services::Search.new(search_type.downcase, search_type)

        expect(search_type.constantize).to receive(:search).with(service.query).and_return([object1, object2])
        service.call
      end
    end

    it 'should call .search on User and return matched users' do
      user1 = create(:user, email: 'mymail1@users.com')
      user2 = create(:user, email: 'mymail2@users.com')
      service = Services::Search.new('users', 'User')

      expect(User).to receive(:search).with(service.query).and_return([user1, user2])
      service.call
    end

    it 'should call .search on ThinkingSphinx and return matched results' do
      question = create(:question, title: 'shared question')
      answer = create(:answer, body: 'shared answer')
      comment = create(:comment, body: 'shared comment')
      user = create(:user, email: 'mail@shared.com')
      search_result = [question, answer, comment, user]
      service = Services::Search.new('shared', 'Global')

      expect(ThinkingSphinx).to receive(:search).with(service.query).and_return(search_result)
      service.call
    end
  end
end
# rubocop:enable Metrics/BlockLength
