# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Answer, type: :model do
  context 'Associations' do
    it { should have_many(:links).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }

    it { should belong_to :question }
    it { should belong_to :user }

    it 'have many attached file' do
      expect(Answer.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
    end
  end

  context 'Validations' do
    let(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question, best: true) }

    it { should validate_presence_of :body }

    it { should accept_nested_attributes_for :links }

    it 'should not allow creation 2nd answer with true value for best field' do
      bad_answer = Answer.new(body: attributes_for(:answer), question: question, best: true)

      expect(bad_answer).to_not be_valid
    end

    it 'should not allow update best field with true value if best answer already exists' do
      bad_answer = create(:answer, question: question)

      bad_answer.best = true
      expect(bad_answer).to_not be_valid
    end
  end

  context 'Methods' do
    describe '#choose_best_answer' do
      let(:user) { create(:user) }
      let(:question) { create(:question) }
      let!(:answer) { create(:answer, question: question, user: user) }

      it 'should assign true to best attribute of answer' do
        answer.choose_best_answer
        answer.reload
        expect(answer).to be_best
      end

      it 'should assign false to existing answer with true value if it exists' do
        second_answer = create(:answer, question: question, best: true)
        answer.choose_best_answer
        second_answer.reload
        expect(second_answer).to_not be_best
      end

      context 'used on question with reward' do
        let(:question_with_reward) { create(:question) }
        let!(:reward) { create(:reward, question: question_with_reward) }
        let(:answer_on_question_with_reward) { create(:answer, question: question_with_reward, user: user) }

        it 'should add reward to user' do
          expect { answer_on_question_with_reward.choose_best_answer }.to change(user.rewards, :count).by(1)
        end

        it 'should not add reward to user if he already owns this reward' do
          answer_on_question_with_reward.choose_best_answer
          expect { answer_on_question_with_reward.choose_best_answer }.to_not change(user.rewards, :count)
        end
      end
    end

    it_behaves_like 'Concern Ratable'
  end

  it 'triggers :broadcast_answer on create & commit' do
    answer_broadcast_data = double('Prepared answer hash for broadcasting')
    question = create(:question)
    answer = build(:answer, question: question)
    expect(answer).to receive(:broadcast_answer).and_return(
      ActionCable.server.broadcast("question_#{question.id}", data: answer_broadcast_data)
    )
    answer.save
  end

  it 'triggers #perform_notification_job after create & commit' do
    answer = build(:answer)
    expect(answer).to receive(:perform_notification_job)
    answer.save
  end

  describe '#perform_notification_job' do
    it 'calls SendNotificationJob#perform_later if user is subscribed to answers question' do
      question = create(:question)
      user = create(:user)
      user.subscribe(question)
      answer = build(:answer, question: question, user: user)
      expect(SendNotificationJob).to receive(:perform_later).with(question)
      answer.save
    end

    it 'does not call SendNotificationJob#perform_later if user is subscribed to answers question' do
      answer = build(:answer)
      expect(SendNotificationJob).to_not receive(:perform_later)
      answer.save
    end
  end
end
# rubocop:enable Metrics/BlockLength
