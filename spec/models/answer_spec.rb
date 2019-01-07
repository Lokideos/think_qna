# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Answer, type: :model do
  context 'Associations' do
    it { should belong_to :question }
    it { should belong_to :user }
  end

  context 'Validations' do
    it { should validate_presence_of :body }

    it 'should not allow creation 2nd answer with true value for best field' do
      question = create(:question)
      create(:answer, question: question, best: true)
      bad_answer = Answer.new(body: attributes_for(:answer), question: question, best: true)

      expect(bad_answer).to_not be_valid
    end

    it 'should throw exception if user tries explicitly update best field for 2nd answer for question' do
      question = create(:question)
      create(:answer, question: question, best: true)
      bad_answer = create(:answer, question: question)

      bad_answer.update!(best: true)
    rescue StandardError => e
      expect(e.message).to eq 'There can be only one best answer for each question.'
    end
  end

  context 'Methods' do
    describe '#choose_best_answer' do
      let(:question) { create(:question) }
      let!(:answer) { create(:answer, question: question) }

      it 'should assign true to best attribute of answer' do
        answer.choose_best_answer
        answer.reload
        expect(answer.best).to be_truthy
      end

      it 'should assign false to existing answer with true value if it exists' do
        second_answer = create(:answer, question: question, best: true)
        answer.choose_best_answer
        second_answer.reload
        expect(second_answer.best).to be_falsey
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
