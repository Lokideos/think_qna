# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'Profiles API' do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  describe 'GET /api/v1/profiles/me' do
    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
      let(:api_path) { '/api/v1/profiles/me' }
    end

    context 'authorized' do
      let(:me) { create(:user) }
      let(:me_response) { json['user'] }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before { get '/api/v1/profiles/me', params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 OK status' do
        expect(response).to be_successful
      end

      it 'returns all public fields' do
        %w[id email created_at updated_at].each do |attr|
          expect(me_response[attr]).to eq me.send(attr).as_json
        end
      end

      it 'does not return private fields' do
        %w[password encrypted_password].each do |attr|
          expect(me_response).to_not have_key(attr)
        end
      end
    end
  end

  describe 'GET /api/v1/profiles' do
    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
      let(:api_path) { '/api/v1/profiles/me' }
    end

    context 'authorized' do
      let(:users) { create_list(:user, 3) }
      let(:me) { users.first }
      let(:users_response) { json['users'] }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before { get '/api/v1/profiles', params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 OK status' do
        expect(response).to be_successful
      end

      it 'returns list of user profiles' do
        expect(users_response.size).to eq 2
      end

      it 'does not return author of the request' do
        expect(users_response).to_not include me
      end

      it 'return all public fields of users' do
        %w[id email created_at updated_at].each do |attr|
          expect(users_response.last[attr]).to eq users.last.send(attr).as_json
        end
      end

      it 'does not return private fields of users' do
        %w[password encrypted_password].each do |attr|
          expect(users_response.last).to_not have_key(attr)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
