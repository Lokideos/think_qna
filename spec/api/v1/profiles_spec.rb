# frozen_string_literal: true

require 'rails_helper'

describe 'Profiles API' do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  describe 'GET /api/v1/profiles/me' do
    context 'unauthorized' do
      it 'returns 401 Unauthorized status if there is no access token' do
        get '/api/v1/profiles/me', headers: headers
        expect(response).to have_http_status 401
      end

      it 'returns 401 Unauthorized status if access token is invalid' do
        get '/api/v1/profiles/me', params: { access_token: '1234' }, headers: headers
        expect(response).to have_http_status 401
      end
    end
  end
end
