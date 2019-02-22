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

    it 'should call .search on Question and return matched questions' do
      question1 = create(:question, title: 'question 1')
      question2 = create(:question, title: 'question 2')
      service = Services::Search.new('question', 'Question')
      expect(Question).to receive(:search).with(service.query).and_return([question1, question2])
      service.call
    end

    it 'should call .search on Answer and return matched answers' do
      answer1 = create(:answer, body: 'answer 1')
      answer2 = create(:answer, body: 'answer 2')
      service = Services::Search.new('answer', 'Answer')
      expect(Answer).to receive(:search).with(service.query).and_return([answer1, answer2])
      service.call
    end

    it 'should call .search on Comment and return matched comments' do
      comment1 = create(:comment, body: 'comment 1')
      comment2 = create(:comment, body: 'comment 2')
      service = Services::Search.new('comment', 'Comment')
      expect(Comment).to receive(:search).with(service.query).and_return([comment1, comment2])
      service.call
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
