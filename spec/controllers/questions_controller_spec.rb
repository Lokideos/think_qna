# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/LineLength
RSpec.describe QuestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:non_author) { create(:user) }
  let(:question) { create(:question, user: user) }

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

    it 'assigns new Link new question to answer' do
      expect(assigns(:answer).links.first).to be_a_new(Link)
    end

    it 'assigns a new Link to question' do
      expect(assigns(:question).links.first).to be_a_new(Link)
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { login(user) }

    before { get :new }

    it 'assigns a new Link to question' do
      expect(assigns(:question).links.first).to be_a_new(Link)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new question in the database' do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(Question, :count).by(1)
      end

      it 'saves the correct association to the user' do
        post :create, params: { question: attributes_for(:question) }
        expect(assigns(:question).user_id).to eq user.id
      end

      it 'creates rating for the question' do
        post :create, params: { question: attributes_for(:question) }
        expect(assigns(:question).rating).to be_a(Rating)
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        expect { post :create, params: { question: attributes_for(:question, :invalid) } }.to_not change(Question, :count)
      end

      it 're-renders new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context 'used by Authenticated user' do
      before { login(user) }

      context 'with valid attributes' do
        it 'assigns the requested question to @question' do
          patch :update, params: { id: question, question: attributes_for(:question), format: :js }
          expect(assigns(:question)).to eq question
        end

        it 'changes question attributes' do
          patch :update, params: { id: question, question: { title: 'new title', body: 'new body' }, format: :js }
          question.reload

          expect(question.title).to eq 'new title'
          expect(question.body).to eq 'new body'
        end

        it 'render update template' do
          patch :update, params: { id: question, question: attributes_for(:question), format: :js }
          expect(response).to render_template :update
        end
      end

      context 'with invalid attributes' do
        before { patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js }

        it 'does not change question' do
          correct_question_title = question.title
          question.reload

          expect(question.title).to eq correct_question_title
          expect(question.body). to eq 'QuestionBody'
        end

        it 're-renders edit update view' do
          expect(response).to render_template :update
        end
      end
    end

    context 'used by user, who is not author of the question' do
      before { login(non_author) }

      it 'does not update the question' do
        correct_question_title = question.title
        patch :update, params: { id: question, question: attributes_for(:question, title: 'Other users title'), format: :js }
        question.reload

        expect(question.title).to eq correct_question_title
      end

      it 'redirects to root path' do
        patch :update, params: { id: question, question: attributes_for(:question, title: 'Other users title'), format: :js }
        expect(response).to redirect_to root_path
      end
    end

    context 'used by unauthenticated user' do
      it 'does not update the question' do
        correct_question_title = question.title
        patch :update, params: { id: question, question: attributes_for(:question, title: 'Unauthenticated users title'), format: :js }
        question.reload

        expect(question.title).to eq correct_question_title
      end

      it 'returns unauthorized 401 status code' do
        patch :update, params: { id: question, question: attributes_for(:question, title: 'Unauthenticated users title'), format: :js }
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:question) { create(:question, user: user) }

    context 'used by Authenticated user' do
      before { login(user) }

      it 'deletes the question' do
        expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
      end

      it 'redirect to index' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_path
      end
    end

    context 'used by user, who is not author of the question' do
      before { login(non_author) }

      it 'does not delete the question from the database' do
        expect { delete :destroy, params: { id: question } }.to_not change(Question, :count)
      end

      it 'redirects to root path' do
        delete :destroy, params: { id: question }

        expect(response).to redirect_to root_path
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not delete the question from the database' do
        expect { delete :destroy, params: { id: question } }.to_not change(Question, :count)
      end

      it 'redirects to login path' do
        delete :destroy, params: { id: question }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PATCH #like' do
    let!(:rating) { create(:rating, ratable: question) }

    context 'used by Authenticated user, who is not author of the question' do
      before { login(non_author) }

      it 'increases question ratings score by 1' do
        rating_count = question.rating.score
        patch :like, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count + 1
      end

      it 'returns OK 200 status' do
        patch :like, params: { id: question, format: :json }

        expect(response).to have_http_status 200
      end
    end

    context 'used by Author of the question' do
      before { login(user) }

      it 'does not increase question rating score by 1' do
        rating_count = question.rating.score
        patch :like, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count
      end

      it 'returns Unprocessable Entity 422 status' do
        patch :like, params: { id: question, format: :json }

        expect(response).to have_http_status 422
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not increase question rating score by 1' do
        rating_count = question.rating.score
        patch :like, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :like, params: { id: question, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end

  describe 'PATCH #dislike' do
    let!(:rating) { create(:rating, ratable: question) }

    context 'used by Authenticated user, who is not author of the question' do
      before { login(non_author) }

      it 'decreases question ratings score by 1' do
        rating_count = question.rating.score
        patch :dislike, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count - 1
      end

      it 'returns OK 200 status' do
        patch :dislike, params: { id: question, format: :json }

        expect(response).to have_http_status 200
      end
    end

    context 'used by Author of the question' do
      before { login(user) }

      it 'does not decrease question rating score by 1' do
        rating_count = question.rating.score
        patch :dislike, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count
      end

      it 'returns Unprocessable Entity 422 status' do
        patch :dislike, params: { id: question, format: :json }

        expect(response).to have_http_status 422
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not decrease question rating score by 1' do
        rating_count = question.rating.score
        patch :dislike, params: { id: question, format: :json }
        question.reload

        expect(question.rating.score).to eq rating_count
      end

      it 'returns Unauthorized 401 status' do
        patch :dislike, params: { id: question, format: :json }

        expect(response).to have_http_status 401
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/BlockLength
