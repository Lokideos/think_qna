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

    it 'assigns a new Comment to @comment' do
      expect(assigns(:comment)).to be_a_new(Comment)
    end

    it 'assigns new comment to question' do
      expect(assigns(:comment)).to be_a_new(Comment)
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

      it 'returns 200 OK status code' do
        patch :update, params: { id: question, question: attributes_for(:question, title: 'Other users title'), format: :js }
        expect(response).to have_http_status 200
      end

      it 'renders exception_alert template' do
        patch :update, params: { id: question, question: attributes_for(:question, title: 'Other users title'), format: :js }
        expect(response).to render_template :exception_alert
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

  describe 'PATCH #Subscribe' do
    let!(:question) { create(:question) }

    context 'used by Authenticated user' do
      before { login(user) }

      it 'creates new subscription in the database' do
        expect { patch :subscribe, params: { id: question, format: :json } }.to change(Subscription, :count).by(1)
      end

      it 'returns 200 OK status' do
        patch :subscribe, params: { id: question, format: :json }
        expect(response).to have_http_status :ok
      end
    end

    context 'used by Authenticated user, who is already subscribed on the question' do
      before { login(user) }
      before { patch :subscribe, params: { id: question, format: :json } }

      it 'does not create new subscription in the database' do
        expect { patch :subscribe, params: { id: question, format: :json } }.to_not change(Subscription, :count)
      end

      it 'returns 403 Forbidden' do
        patch :subscribe, params: { id: question, format: :json }
        expect(response).to have_http_status :forbidden
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not create new subscription in the database' do
        expect { patch :subscribe, params: { id: question, format: :json } }.to_not change(Subscription, :count)
      end

      it 'returns 401 Unauthorized status' do
        patch :subscribe, params: { id: question, format: :json }
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'PATCH #Unsubscribe' do
    let!(:question) { create(:question) }

    context 'used by Authenticated user' do
      before { login(user) }

      before { user.subscribe(question) }

      it 'deletes current subscription from the database' do
        expect { patch :unsubscribe, params: { id: question, format: :json } }.to change(Subscription, :count).by(-1)
      end

      it 'returns 200 OK status' do
        patch :unsubscribe, params: { id: question, format: :json }
        expect(response).to have_http_status :ok
      end
    end

    context 'used by Authenticated user, who has no subscription to question' do
      before { login(user) }

      it 'does not delete any subscription from the database' do
        expect { patch :unsubscribe, params: { id: question, format: :json } }.to_not change(Subscription, :count)
      end

      it 'returns 403 Forbidden status' do
        patch :unsubscribe, params: { id: question, format: :json }
        expect(response).to have_http_status :forbidden
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not delete any subscription from the database' do
        expect { patch :unsubscribe, params: { id: question, format: :json } }.to_not change(Subscription, :count)
      end

      it 'returns 401 Unauthorized status' do
        patch :unsubscribe, params: { id: question, format: :json }
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  it_behaves_like 'Concern Rated' do
    let(:resource) { question }
  end
end
# rubocop:enable Metrics/LineLength
# rubocop:enable Metrics/BlockLength
