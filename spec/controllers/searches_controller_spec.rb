# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SearchesController, type: :controller do
  describe 'GET #general_search' do
    it 'assigns parameters to cookies' do
      get :general_search, params: { query: 'example_query', search_type: 'Question' }

      expect(response.cookies['search.query']).to eq 'example_query'
      expect(response.cookies['search.search_type']).to eq 'Question'
    end

    context 'with valid parameters' do
      it 'redirects to search_result' do
        get :general_search, params: { query: 'example_query', search_type: 'Question' }
        expect(response).to redirect_to search_result_searches_path
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
      request.cookies['search.query'] = 'example_query'
      request.cookies['search.search_type'] = 'Question'
      ThinkingSphinx::Test.run { get :search_result }
    end

    it 'assigns search results to @search_result' do
      expect(assigns(:search_result)).to eq request.cookies['search.search_type'].constantize.search(
        request.cookies['search.query']
      )
    end

    it 'renders :search_result template' do
      expect(response).to render_template :search_result
    end
  end
end
# rubocop:enable Metrics/BlockLength
