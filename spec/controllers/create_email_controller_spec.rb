# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CreateEmailController, type: :controller do
  describe 'GET #show' do
    before { get :show }

    it 'assigns new user to @user' do
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders show template' do
      expect(response).to render_template :show
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      session['devise.provider'] = 'github'
      session['devise.uid'] = '12345'
    end

    context 'with valid attributes' do
      context 'while user already exists' do
        let(:user) { create(:user) }

        it 'creates authorization for user in the database' do
          expect { post :create, params: { user: { email: user.email } } }.to change(user.authorizations, :count).by(1)
        end

        it 'redirects to the login path' do
          post :create, params: { user: { email: user.email } }

          expect(response).to redirect_to new_user_session_path
        end
      end

      context 'while user does not exist' do
        it 'creates new user in the database' do
          expect { post :create, params: { user: attributes_for(:user, :only_email) } }.to change(User, :count).by(1)
        end

        it 'creates authorization for newly created user in the database' do
          expect do
            post :create, params: { user: attributes_for(:user, :only_email) }
          end.to change(Authorization, :count).by(1)
        end

        it 'redirects to the root path' do
          post :create, params: { user: attributes_for(:user, :only_email) }

          expect(response).to redirect_to root_path
        end
      end
    end

    context 'with invalid attributes' do
      it 'does not create new authorization in the database' do
        expect do
          post :create, params: { user: attributes_for(:user, :invalid_email) }
        end.to_not change(Authorization, :count)
      end

      it 're-renders show template' do
        post :create, params: { user: attributes_for(:user, :invalid_email) }

        expect(response).to render_template :show
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
