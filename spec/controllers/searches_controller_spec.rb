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
    let(:service) { double('Services::Search') }

    before { allow(Services::Search).to receive(:new).and_return(service) }

    it 'calls search service' do
      expect(service).to receive(:call)
      get :search_result, params: { query: 'some_query', search_type: 'correct_type' }
    end

    it 'renders :search_result template' do
      allow(service).to receive(:call)
      get :search_result, params: { query: 'some_query', search_type: 'correct_type' }
      expect(response).to render_template :search_result
    end
  end
end
