# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe QuestionsController, type: :controller do
  describe 'GET #index' do
    before { get :index }

    let(:questions) { create_list(:question, 3) }

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    let(:question) { create(:question) }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'redners show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { get :new }
    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'render new view' do
      expect(response).to render_template :new
    end
  end
end
# rubocop:enable Metrics/BlockLength
