# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SearchesController, type: :controller do
  describe 'GET #general_search' do
    context 'with valid parameters' do
      it 'redirects to search_result' do
        get :general_search, params: { query: 'example_query', search_type: 'Question' }

        expect(response).to redirect_to action: :search_result, query: 'example_query', search_type: 'Question'
      end
    end

    context 'with invalid parameters' do
      it 'redirects to questions path' do
        get :general_search, params: { query: '', search_type: 'bad_type' }

        expect(response).to redirect_to questions_path
      end
    end
  end

  describe 'GET #search_result' do
    context 'with questions' do
      let(:question_1) { create(:question, title: 'Question Title 1') }
      let(:question_2) { create(:question, title: 'Question Title 2') }

      before do
        allow(Question).to receive(:search).with('Title 1').and_return([question_1, question_2])
        get :search_result, params: { query: 'Title 1', search_type: 'Question' }
      end

      it 'assigns search results to @search_result' do
        expect(assigns(:search_result)).to match_array [question_1, question_2]
      end

      it 'renders :search_result template' do
        expect(response).to render_template :search_result
      end
    end

    context 'with answers' do
      let(:answer_1) { create(:answer, body: 'Answer Body 1') }
      let(:answer_2) { create(:answer, body: 'Answer Body 2') }

      before do
        allow(Answer).to receive(:search).with('Answer').and_return([answer_1, answer_2])
        get :search_result, params: { query: 'Answer', search_type: 'Answer' }
      end

      it 'assigns search results to @search_result' do
        expect(assigns(:search_result)).to match_array [answer_1, answer_2]
      end

      it 'renders :search_result template' do
        expect(response).to render_template :search_result
      end
    end

    context 'with comments' do
      let(:comment_1) { create(:comment, body: 'Comment Body 1') }
      let(:comment_2) { create(:comment, body: 'Comment Body 2') }

      before do
        allow(Comment).to receive(:search).with('Comment').and_return([comment_1, comment_2])
        get :search_result, params: { query: 'Comment', search_type: 'Comment' }
      end

      it 'assigns search results to @search_result' do
        expect(assigns(:search_result)).to match_array [comment_1, comment_2]
      end

      it 'renders :search_result template' do
        expect(response).to render_template :search_result
      end
    end

    context 'with users' do
      let(:user_1) { create(:user, email: 'user@email.com') }
      let(:user_2) { create(:user, email: 'user2@email.com') }

      before do
        allow(User).to receive(:search).with('email.com').and_return([user_1, user_2])
        get :search_result, params: { query: 'email.com', search_type: 'User' }
      end

      it 'assigns search results to @search_result' do
        expect(assigns(:search_result)).to match_array [user_1, user_2]
      end

      it 'renders :search_result template' do
        expect(response).to render_template :search_result
      end
    end

    context 'with global search' do
      let(:user) { create(:user, email: 'global@email.com') }
      let(:comment) { create(:comment, body: 'Global Comment') }
      let(:answer) { create(:answer, body: 'Global Answer') }
      let(:question) { create(:question, title: 'Question global') }
      let(:search_results) { [user, comment, answer, question] }

      before do
        allow(ThinkingSphinx).to receive(:search).with('global').and_return(search_results)
        get :search_result, params: { query: 'global', search_type: 'Global' }
      end

      it 'assigns search results to @search_result' do
        expect(assigns(:search_result)).to match_array search_results
      end

      it 'renders :search_result template' do
        expect(response).to render_template :search_result
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
