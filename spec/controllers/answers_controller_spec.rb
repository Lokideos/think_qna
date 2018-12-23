# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/LineLength
RSpec.describe AnswersController, type: :controller do
  let(:question) { create(:question) }
  let(:answer) { create(:answer, question: question) }
  let(:user) { create(:user) }

  describe 'GET #index' do
    let(:answers) do
      question
      create_list(:answer, 3)
    end

    before { get :index, params: { question_id: question } }

    it 'populates an array of all answers' do
      expect(assigns(:answers)).to match_array(answers)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    let(:answer) { create(:answer, question: question) }

    before { get :show, params: { id: answer } }

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { login(user) }

    before { get :new, params: { question_id: question } }

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before { login(user) }

    before { get :edit, params: { id: answer } }

    it 'renders edit view' do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves the answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer), question_id: question } }.to change(Answer, :count).by(1)
      end

      it 'saves the correct association to the question' do
        post :create, params: { answer: attributes_for(:answer), question_id: question }
        expect(assigns(:answer).question_id).to eq question.id
      end

      it 'redirects the show view' do
        post :create, params: { answer: attributes_for(:answer), question_id: question }
        expect(response).to redirect_to question
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer in the database' do
        expect { post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question } }.to_not change(Answer, :count)
      end

      it 'redirects to the questions show view' do
        post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question }
        expect(response).to redirect_to question
      end
    end
  end

  describe 'PATCH #update' do
    before { login(user) }

    it 'assigns the requested answer to @answer' do
      patch :update, params: { id: answer, answer: attributes_for(:answer) }
      expect(assigns(:answer)).to eq answer
    end

    context 'with valid attributes' do
      it 'changes the answer attributes' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }
        answer.reload
        expect(answer.body).to eq 'new body'
      end

      it 'redirect to the updated answer' do
        patch :update, params: { id: answer, answer: attributes_for(:answer) }
        expect(response).to redirect_to question
      end
    end

    context 'with invalid attributes' do
      before { patch :update, params: { id: answer, answer: { body: nil } } }

      it 'does not change the answer attributes' do
        correct_answer_body = answer.body
        answer.reload

        expect(answer.body).to eq correct_answer_body
      end

      it 're-renders edit view' do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    before { login(user) }

    let!(:answer) { create(:answer, question: question) }

    it 'deletes the answer' do
      expect { delete :destroy, params: { id: answer } }.to change(Answer, :count).by(-1)
    end

    it 'redirects to the associated question view' do
      delete :destroy, params: { id: answer }
      expect(response).to redirect_to question
    end
  end
end
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/BlockLength
