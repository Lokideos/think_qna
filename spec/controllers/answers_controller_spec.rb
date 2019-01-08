# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/LineLength
RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:non_author) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves the answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js }.to change(Answer, :count).by(1)
      end

      it 'saves the correct association to the question' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, format: :js }
        expect(assigns(:answer).question_id).to eq question.id
      end

      it 'saves the correct association to the user' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, format: :js }
        expect(assigns(:answer).user_id).to eq user.id
      end

      it 'render the create view' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, format: :js }
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question }, format: :js }.to_not change(Answer, :count)
      end

      it 'redirects to the questions show view' do
        post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question, format: :js }
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    before { login(user) }

    it 'assigns the requested answer to @answer' do
      patch :update, params: { id: answer, answer: attributes_for(:answer), format: :js }
      expect(assigns(:answer)).to eq answer
    end

    context 'with valid attributes' do
      it 'changes the answer attributes' do
        patch :update, params: { id: answer, answer: { body: 'new body' }, format: :js }
        answer.reload
        expect(answer.body).to eq 'new body'
      end

      it 'renders update template' do
        patch :update, params: { id: answer, answer: attributes_for(:answer), format: :js }
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      before { patch :update, params: { id: answer, answer: { body: nil }, format: :js } }

      it 'does not change the answer attributes' do
        correct_answer_body = answer.body
        answer.reload

        expect(answer.body).to eq correct_answer_body
      end

      it 're-renders update template' do
        expect(response).to render_template :update
      end
    end

    context 'used by user, who is not author of the answer' do
      it 'does not update the answer' do
        login(non_author)
        correct_answer_body = answer.body
        patch :update, params: { id: answer, answer: attributes_for(:answer, body: 'Other users body') }
        answer.reload

        expect(answer.body).to eq correct_answer_body
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'DELETE #destroy' do
    before { login(user) }

    let!(:answer) { create(:answer, user: user) }

    it 'deletes the answer' do
      expect { delete :destroy, params: { id: answer, format: :js } }.to change(Answer, :count).by(-1)
    end

    it 'render destroy template' do
      delete :destroy, params: { id: answer, format: :js }
      expect(response).to render_template :destroy
    end

    context 'used by user, who is not author of the answer' do
      it 'does not delete the answer' do
        login(non_author)

        expect { delete :destroy, params: { id: answer, format: :js } }.to_not change(Answer, :count)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'PATCH #choose_best' do
    before { login(user) }

    it 'changes needed answer attributes' do
      patch :choose_best, params: { id: answer, format: :js }
      answer.reload
      expect(answer.best).to be_truthy
    end

    it 'changes needed attributes for other answers' do
      other_answer = create(:answer, question: question, best: true)
      patch :choose_best, params: { id: answer, format: :js }
      other_answer.reload
      expect(other_answer.best).to be_falsey
    end

    it 'renders choose_best template' do
      patch :choose_best, params: { id: answer, format: :js }
      expect(response).to render_template :choose_best
    end
  end

  context 'used by user, who is not author of the related question' do
    let(:other_answer) { create(:answer, question: question, user: user) }

    before { login(non_author) }

    it 'does not change best status of the answer' do
      patch :choose_best, params: { id: other_answer, format: :js }
      answer.reload
      expect(answer).to_not be_best
    end

    it 'redirect to root path' do
      patch :choose_best, params: { id: answer, format: :js }
      expect(response).to redirect_to root_path
    end
  end
end
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/BlockLength
