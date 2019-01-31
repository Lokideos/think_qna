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
    context 'unauthorized' do
      it 'returns 401 Unauthorized status if there is no access token' do
        get "/api/v1/answers/#{answer.id}", headers: headers
        expect(response).to have_http_status 401
      end

      it 'returns 401 Unauthorized status if access token is invalid' do
        get '/api/v1/questions', params: { access_token: '1234' }, headers: headers
        expect(response).to have_http_status 401
      end
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

      context 'comments' do
        let(:comments_response) { answer_response['comments'] }

        it 'contains comments' do
          expect(comments_response.first['id']).to eq comment.id
        end

        it 'contains all comments' do
          expect(comments_response.size).to eq 3
        end

        it 'returns all public fields of comments' do
          %w[id body created_at updated_at].each do |attr|
            expect(comments_response.first[attr]).to eq comment.send(attr).as_json
          end
        end
      end

      context 'file links' do
        let(:files_response) { answer_response['files'] }

        before { answer.files.attach(create_file_blob) }
        before { get "/api/v1/answers/#{answer.id}", params: { access_token: access_token.token }, headers: headers }

        it 'contains files' do
          expect(files_response.first['id']).to eq answer.files.first.id
        end

        it 'contains link for files' do
          %w[id service_url].each do |attr|
            expect(files_response.first[attr]).to eq answer.files.first.send(attr).as_json
          end
        end

        it 'contains only allowed data' do
          expect(files_response.first.size).to eq 2
        end
      end

      context 'links' do
        let(:links_response) { answer_response['links'] }

        it 'contains links' do
          expect(links_response.first['id']).to eq link.id
        end

        it 'contain all related to question links' do
          expect(links_response.size).to eq 2
        end

        it 'contains url for links' do
          %w[id url].each do |attr|
            expect(links_response.first[attr]).to eq link.send(attr).as_json
          end
        end

        it 'contains only allowed data' do
          expect(links_response.first.size).to eq 2
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
