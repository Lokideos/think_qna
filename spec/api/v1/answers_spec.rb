# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'Answers API' do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  let(:answer) { create(:answer) }

  describe 'GET /api/v1/answers/:id' do
    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
      let(:api_path) { "/api/v1/answers/#{answer.id}" }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answer_response) { json['answer'] }
      let!(:comments) { create_list(:comment, 3, commentable: answer) }
      let(:comment) { comments.first }
      let!(:links) { create_list(:link, 2, linkable: answer) }
      let(:link) { links.last }

      before { get "/api/v1/answers/#{answer.id}", params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 OK status' do
        expect(response).to have_http_status 200
      end

      it 'returns all public fields' do
        %w[id body created_at updated_at].each do |attr|
          expect(answer_response[attr]).to eq answer.send(attr).as_json
        end
      end

      it_behaves_like 'API Commentable' do
        let(:resource_response_with_comments) { answer_response['comments'] }
      end

      it_behaves_like 'API Filable' do
        let(:resource_response_with_files) { answer_response['files'] }
        let(:resource) { answer }
        let(:method) { :get }
        let(:api_path) { "/api/v1/answers/#{answer.id}" }
      end

      it_behaves_like 'API Linkable' do
        let(:resource_response_with_links) { answer_response['links'] }
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
