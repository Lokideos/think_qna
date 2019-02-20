# frozen_string_literal: true

require 'rails_helper'

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
    before do
      ThinkingSphinx::Test.run { get :search_result, params: { query: 'example_query', search_type: 'Question' } }
    end

    it 'assigns search results to @search_result' do
      expect(assigns(:search_result)).to eq request.params['search_type'].constantize.search(request.params['query'])
    end

    it 'renders :search_result template' do
      expect(response).to render_template :search_result
    end
  end
end
