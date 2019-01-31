# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'Questions API' do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  describe 'GET /api/v1/questions' do
    context 'unauthorized' do
      it 'returns 401 Unauthorized status if there is no access token' do
        get '/api/v1/questions', headers: headers
        expect(response).to have_http_status 401
      end

      it 'returns 401 Unauthorized status if access token is invalid' do
        get '/api/v1/questions', params: { access_token: '1234' }, headers: headers
        expect(response).to have_http_status 401
      end
    end

    context 'authorized' do
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:questions_response) { json['questions'] }
      let(:access_token) { create(:access_token) }

      before { get '/api/v1/questions', params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 OK status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(questions_response.size).to eq 2
      end

      it 'contains user object' do
        expect(questions_response.first['user']['id']).to eq question.user_id
      end

      it 'returns all public fields' do
        %w[id title body created_at updated_at].each do |attr|
          expect(questions_response.first[attr]).to eq question.send(attr).as_json
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
