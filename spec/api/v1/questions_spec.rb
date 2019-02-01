# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'Questions API' do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  describe 'GET /api/v1/questions' do
    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
      let(:api_path) { '/api/v1/questions' }
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

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
      let(:api_path) { "/api/v1/questions/#{question.id}" }
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

      it_behaves_like 'API Commentable' do
        let(:resource_response_with_comments) { question_response['comments'] }
      end

      it_behaves_like 'API Filable' do
        let(:resource_response_with_files) { question_response['files'] }
        let(:resource) { question }
        let(:method) { :get }
        let(:api_path) { "/api/v1/questions/#{question.id}" }
      end

      it_behaves_like 'API Linkable' do
        let(:resource_response_with_links) { question_response['links'] }
      end
    end
  end

  describe 'GET /api/v1/questions/:id/answers' do
    let!(:question) { create(:question) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
      let(:api_path) { "/api/v1/questions/#{question.id}/answers" }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:answers) { create_list(:answer, 3, question: question) }
      let(:answer) { answers.first }
      let(:answer_response) { json['answers'] }

      before do
        get "/api/v1/questions/#{question.id}/answers", params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 OK status' do
        expect(response).to be_successful
      end

      it 'returns list of answers' do
        expect(answer_response.size).to eq 3
      end

      it 'returns all answers public fields' do
        %w[id body created_at updated_at user_id].each do |attr|
          expect(answer_response.first[attr]).to eq answer.send(attr).as_json
        end
      end
    end
  end

  describe 'POST /api/v1/questions' do
    it_behaves_like 'API Authorizable' do
      let(:headers) { nil }
      let(:method) { :post }
      let(:api_path) { '/api/v1/questions' }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }

      context 'with valid attributes' do
        it 'returns 200 status' do
          post '/api/v1/questions',
               params: { question: attributes_for(:question), access_token: access_token.token, format: :json }
          expect(response).to be_successful
        end

        it 'create new question in the database' do
          expect do
            post '/api/v1/questions',
                 params: { question: attributes_for(:question), access_token: access_token.token, format: :json }
          end.to change(Question, :count).by(1)
        end

        it 'creates question with correct attributes' do
          post '/api/v1/questions',
               params: {
                 question: { title: 'Q-Title', body: 'Q-Body' },
                 access_token: access_token.token,
                 format: :json
               }
          expect(Question.last.title).to eq 'Q-Title'
          expect(Question.last.body).to eq 'Q-Body'
        end
      end

      context 'with invalid attributes' do
        it 'returns 422 Unprocessable entity status' do
          post '/api/v1/questions',
               params: {
                 question: attributes_for(:question, :invalid),
                 access_token: access_token.token,
                 format: :json
               }
          expect(response).to have_http_status 422
        end

        it 'does not save question in the database' do
          expect do
            post '/api/v1/questions', params: {
              question: attributes_for(:question, :invalid),
              access_token: access_token.token,
              format: :json
            }
          end.to_not change(Question, :count)
        end
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:user) { create(:user) }
    let!(:question) { create(:question, user: user) }

    it_behaves_like 'API Authorizable' do
      let(:headers) { nil }
      let(:method) { :patch }
      let(:api_path) { "/api/v1/questions/#{question.id}" }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      context 'with valid attributes' do
        it 'returns 200 status' do
          patch "/api/v1/questions/#{question.id}",
                params: { question: attributes_for(:question), access_token: access_token.token, format: :json }
          expect(response).to be_successful
        end

        it 'updates the question' do
          patch "/api/v1/questions/#{question.id}",
                params: { question: { title: 'Updated Title' }, access_token: access_token.token, format: :json }
          question.reload

          expect(question.title).to eq 'Updated Title'
        end
      end

      context 'with invalid attributes' do
        it 'returns 422 status' do
          patch "/api/v1/questions/#{question.id}",
                params: {
                  question: attributes_for(:question, :invalid),
                  access_token: access_token.token,
                  format: :json
                }
          expect(response).to have_http_status 422
        end

        it 'does not update the question' do
          correct_title = question.title
          patch "/api/v1/questions/#{question.id}",
                params: { question: { title: nil }, access_token: access_token.token, format: :json }
          question.reload

          expect(question.title).to eq correct_title
        end
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:user) { create(:user) }
    let!(:question) { create(:question, user: user) }

    it_behaves_like 'API Authorizable' do
      let(:headers) { nil }
      let(:method) { :delete }
      let(:api_path) { "/api/v1/questions/#{question.id}" }
    end

    it_behaves_like 'API Deletable' do
      let(:method) { :delete }
      let(:api_path) { "/api/v1/questions/#{question.id}" }
      let(:resource) { question }
    end
  end
end
# rubocop:enable Metrics/BlockLength
