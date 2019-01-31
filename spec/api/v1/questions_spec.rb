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

  describe 'GET /api/v1/questions/:id' do
    let!(:question) { create(:question) }

    context 'unauthorized' do
      it 'returns 401 Unauthorized status if there is no access token' do
        get "/api/v1/questions/#{question.id}", headers: headers
        expect(response).to have_http_status 401
      end

      it 'returns 401 Unauthorized status if access token is invalid' do
        get "/api/v1/questions/#{question.id}", params: { access_token: '1234' }, headers: headers
        expect(response).to have_http_status 401
      end
    end

    context 'authorized' do
      let!(:comments) { create_list(:comment, 3, commentable: question) }
      let!(:links) { create_list(:link, 2, linkable: question) }
      let(:link) { links.last }
      let(:comment) { comments.first }
      let(:access_token) { create(:access_token) }
      let(:question_response) { json['question'] }

      before { get "/api/v1/questions/#{question.id}", params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 OK status' do
        expect(response).to be_successful
      end

      it 'returns all public fields' do
        %w[id title body created_at updated_at].each do |attr|
          expect(question_response[attr]).to eq question.send(attr).as_json
        end
      end

      context 'comments' do
        let(:comments_response) { question_response['comments'] }

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
        let(:files_response) { question_response['files'] }

        before { question.files.attach(create_file_blob) }
        before { get "/api/v1/questions/#{question.id}", params: { access_token: access_token.token }, headers: headers }

        it 'contains files' do
          expect(files_response.first['id']).to eq question.files.first.id
        end

        it 'contains link for files' do
          %w[id service_url].each do |attr|
            expect(files_response.first[attr]).to eq question.files.first.send(attr).as_json
          end
        end

        it 'contains only allowed data' do
          expect(files_response.first.size).to eq 2
        end
      end

      context 'links' do
        let(:links_response) { question_response['links'] }

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
