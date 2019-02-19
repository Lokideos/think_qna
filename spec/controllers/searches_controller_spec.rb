# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SearchesController, type: :controller do
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates search in the database' do
        expect { post :create, params: { search: attributes_for(:search) } }.to change(Search, :count).by(1)
      end

      it 'redirects to created search' do
        post :create, params: { search: attributes_for(:search) }
        expect(response).to redirect_to assigns(:search)
      end
    end

    context 'with invalid attributes' do
      let(:questions) { create_list(:question, 3) }

      it 'does not create search in the database' do
        expect { post :create, params: { search: attributes_for(:search, :invalid) } }.to_not change(Search, :count)
      end

      it 'populates an array of questions' do
        post :create, params: { search: attributes_for(:search, :invalid) }
        expect(assigns(:questions)).to match_array(questions)
      end

      it 're-renders questions index view' do
        post :create, params: { search: attributes_for(:search, :invalid) }
        expect(response).to render_template 'questions/index'
      end
    end
  end

  describe 'GET #show' do
    let(:search) { create(:search) }

    before { ThinkingSphinx::Test.run { get :show, params: { id: search } } }

    it 'renders :show template' do
      expect(response).to render_template :show
    end

    it 'assigns search results to @search_result' do
      expect(assigns(:search_result)).to eq Question.search(search.query)
    end
  end
end
# rubocop:enable Metrics/BlockLength
