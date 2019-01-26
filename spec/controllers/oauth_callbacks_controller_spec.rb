# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe OauthCallbacksController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET #github' do
    let(:oauth_data) { { 'provider' => 'Github', 'uid' => '11111' } }

    it 'find user from oauth data' do
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
      expect(User).to receive(:find_for_oauth).with(oauth_data)
      get :github
    end

    context 'with existing user' do
      let!(:user) { create(:user) }

      before do
        allow(User).to receive(:find_for_oauth).and_return(user)
        get :github
      end

      it 'login user' do
        expect(subject.current_user).to eq user
      end

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'with non existing user' do
      let!(:user) { build(:user) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
        allow(User).to receive(:find_for_oauth)
        get :github
      end

      it 'does not login user' do
        expect(subject.current_user).to_not be
      end

      it 'redirects to email creation page' do
        expect(response).to redirect_to create_email_show_path
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
