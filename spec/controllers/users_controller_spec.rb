# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe UsersController, type: :controller do
  describe 'GET #rewards' do
    let(:user) { create(:user) }
    let(:non_author) { create(:user) }
    let(:rewards_list) { create_list(:reward, 3, user: user) }

    context 'used by user, who owns those rewards' do
      before { login(user) }

      before { get :rewards, params: { id: user } }

      it 'assigns rewards to Rewards' do
        expect(assigns(:rewards)).to eq rewards_list
      end

      it 'renders rewards template' do
        expect(response).to render_template :rewards
      end
    end

    context 'used by other user' do
      before { login(non_author) }

      before { get :rewards, params: { id: user } }

      it 'does not assign rewards to Rewards' do
        expect(assigns(:rewards)).to_not eq rewards_list
      end

      it 'redirects to root path' do
        get :rewards, params: { id: user }
        expect(response).to redirect_to root_path
      end
    end

    context 'used by unauthenticated user' do
      before { get :rewards, params: { id: user } }

      it 'does not assign rewards to Rewards' do
        expect(assigns(:rewards)).to_not eq rewards_list
      end

      it 'redirects to login path' do
        get :rewards, params: { id: user }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
