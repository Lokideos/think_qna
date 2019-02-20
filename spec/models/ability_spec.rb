# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe Ability do
  subject(:ability) { Ability.new(user) }

  context 'as a guest user' do
    let(:user) { nil }

    it { should be_able_to :read, Question }
    it { should be_able_to :read, Answer }
    it { should be_able_to :read, Comment }

    it { should_not be_able_to :manage, :all }

    it { should be_able_to :create, :create_email }
    it { should be_able_to :authenticate, :oauth_provider }

    it { should be_able_to :search, :general_search }
    it { should be_able_to :search, :search_result }
  end

  context 'as admin user' do
    let(:user) { create(:user, admin: true) }

    it { should be_able_to :manage, :all }
  end

  context 'as a general user' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:non_author_question) { create(:question, user: other_user) }
    let(:author_attachment_resource) { create(:question, user: user) }
    let(:attachment_resource) { create(:question) }
    let(:rated_question) { create(:question, user: other_user) }
    let(:rated_answer) { create(:answer, user: other_user) }

    it { should be_able_to :read, :all }

    it { should be_able_to :create, Question }
    it { should be_able_to :create, Answer }
    it { should be_able_to :create, Comment }

    it { should be_able_to :update, create(:question, user: user) }
    it { should be_able_to :update, create(:answer, user: user) }
    it { should_not be_able_to :update, create(:question, user: other_user) }
    it { should_not be_able_to :update, create(:answer, user: other_user) }

    it { should be_able_to :destroy, create(:question, user: user) }
    it { should be_able_to :destroy, create(:answer, user: user) }
    it { should be_able_to :destroy, create(:comment, user: user) }
    it { should be_able_to :destroy, create(:link, linkable: create(:question, user: user)) }
    it { should_not be_able_to :destroy, create(:question, user: other_user) }
    it { should_not be_able_to :destroy, create(:answer, user: other_user) }
    it { should_not be_able_to :destroy, create(:comment, user: other_user) }
    it { should_not be_able_to :destroy, create(:link, linkable: create(:question, user: other_user)) }

    it { should be_able_to :like, create(:question, user: other_user) }
    it { should be_able_to :like, create(:answer, user: other_user) }
    it { should_not be_able_to :like, create(:question, user: user) }
    it { should_not be_able_to :like, create(:answer, user: user) }

    it { should be_able_to :dislike, create(:question, user: other_user) }
    it { should be_able_to :dislike, create(:answer, user: other_user) }
    it { should_not be_able_to :dislike, create(:question, user: user) }
    it { should_not be_able_to :dislike, create(:answer, user: user) }

    it do
      rated_question.rating.score_up(user)
      should be_able_to :unlike, rated_question
    end

    it do
      rated_answer.rating.score_up(user)
      should be_able_to :unlike, rated_answer
    end

    it { should_not be_able_to :unlike, create(:question, user: user) }
    it { should_not be_able_to :unlike, create(:answer, user: user) }

    it { should be_able_to :choose_best, create(:answer, question: question) }
    it { should_not be_able_to :choose_best, create(:answer, question: non_author_question) }

    it { should be_able_to :check_rewards, user }
    it { should_not be_able_to :check_rewards, other_user }

    context 'attachment tests' do
      before do
        attachment_resource.files.attach(create_file_blob)
        author_attachment_resource.files.attach(create_file_blob)
      end

      it { should be_able_to :destroy, author_attachment_resource.files.last }
      it { should_not be_able_to :destroy, attachment_resource.files.last }
    end

    it { should be_able_to :subscribe, create(:question) }

    it do
      question = create(:question)
      user.subscribe(question)
      should_not be_able_to :subscribe, question
    end

    it do
      question = create(:question)
      user.subscribe(question)
      should be_able_to :unsubscribe, question
    end

    it { should_not be_able_to :unsubscribe, create(:question) }
  end

  describe '#ratable??' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:non_author_question) { create(:question) }

    it 'should return true if user is not author of ratable item' do
      expect(subject).to be_ratable(non_author_question)
    end

    it 'should return false if user is author of ratable item' do
      expect(subject).to_not be_ratable(question)
    end
  end
end
# rubocop:enable Metrics/BlockLength
