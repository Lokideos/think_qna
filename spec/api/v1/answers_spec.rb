# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'Answers API' do
  let(:headers) do
    { 'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json' }
  end

  let(:answer) { create(:answer) }

  describe 'GET /api/v1/questions/:id/answers' do
    let!(:question) { create(:question) }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:answers) { create_list(:answer, 3, question: question) }
      let(:answer) { answers.first }
      let(:answer_response) { json['answers'] }

      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
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

  describe 'GET /api/v1/answers/:id' do
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answer_response) { json['answer'] }
      let!(:comments) { create_list(:comment, 3, commentable: answer) }
      let(:comment) { comments.first }
      let!(:links) { create_list(:link, 2, linkable: answer) }
      let(:link) { answer.links.order(created_at: :desc).first }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 OK status' do
        expect(response).to have_http_status :ok
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
      end

      it_behaves_like 'API Linkable' do
        let(:resource_response_with_links) { answer_response['links'] }
      end
    end
  end

  describe 'POST /api/v1/questions/:id/answers' do
    let!(:question) { create(:question) }

    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }
    it_behaves_like 'API Authorizable' do
      let(:headers) { nil }
      let(:method) { :post }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }

      context 'with valid attributes' do
        it 'returns 201 Created status' do
          post api_path,
               params: { answer: attributes_for(:answer), access_token: access_token.token, format: :json }
          expect(response).to have_http_status :created
        end

        it 'create new answer in the database' do
          expect do
            post api_path, params: { answer: attributes_for(:answer), access_token: access_token.token, format: :json }
          end.to change(Answer, :count).by(1)
        end

        it 'assign correct user association to newly created answer' do
          post api_path, params: { answer: attributes_for(:answer), access_token: access_token.token, format: :json }
          expect(Answer.first.user_id). to eq access_token.resource_owner_id
        end

        it 'assign correct question association to newly created answer' do
          post api_path, params: {
            answer: attributes_for(:answer, question: question), access_token: access_token.token, format: :json
          }
          expect(Answer.first.question_id).to eq question.id
        end

        it 'creates answer with correct attributes' do
          post api_path,
               params: {
                 answer: { body: 'A-Body' },
                 access_token: access_token.token,
                 format: :json
               }
          expect(question.answers.last.body).to eq 'A-Body'
          expect(Answer.last.question_id).to eq question.id
        end

        it 'returns created object' do
          post api_path,
               params: {
                 answer: attributes_for(:answer),
                 access_token: access_token.token,
                 format: :json
               }

          expect(Answer.find(json['answer']['id'])).to be_a(Answer)
        end
      end

      context 'with invalid attributes' do
        it 'returns 422 Unprocessable entity status' do
          post api_path,
               params: {
                 answer: attributes_for(:answer, :invalid),
                 access_token: access_token.token,
                 format: :json
               }
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'does not save answer in the database' do
          expect do
            post api_path, params: {
              answer: attributes_for(:answer, :invalid),
              access_token: access_token.token,
              format: :json
            }
          end.to_not change(Answer, :count)
        end

        it 'returns error messages' do
          post api_path,
               params: { answer: { body: nil }, access_token: access_token.token, format: :json }

          expect(json).to include "Body can't be blank"
        end
      end
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let!(:answer) { create(:answer, user: user) }

    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    it_behaves_like 'API Authorizable' do
      let(:headers) { nil }
      let(:method) { :patch }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      context 'with valid attributes' do
        it 'returns 200 OK status' do
          patch api_path,
                params: { answer: attributes_for(:answer), access_token: access_token.token, format: :json }
          expect(response).to have_http_status :ok
        end

        it 'updates the answer' do
          patch api_path,
                params: { answer: { body: 'Updated Body' }, access_token: access_token.token, format: :json }
          answer.reload

          expect(answer.body).to eq 'Updated Body'
        end

        it 'returns updated object' do
          patch api_path,
                params: { answer: attributes_for(:answer), access_token: access_token.token, format: :json }

          expect(Answer.find(json['answer']['id'])).to be_a(Answer)
        end
      end

      context 'with invalid attributes' do
        it 'returns 422 status' do
          patch api_path,
                params: {
                  answer: attributes_for(:answer, :invalid),
                  access_token: access_token.token,
                  format: :json
                }
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'does not update the answer' do
          correct_body = answer.body
          patch api_path,
                params: { answer: { body: nil }, access_token: access_token.token, format: :json }
          answer.reload

          expect(answer.body).to eq correct_body
        end

        it 'returns error messages' do
          patch api_path,
                params: { answer: { body: nil }, access_token: access_token.token, format: :json }

          expect(json).to include "Body can't be blank"
        end
      end
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let!(:answer) { create(:answer, user: user) }

    let(:api_path) { "/api/v1/answers/#{answer.id}" }
    it_behaves_like 'API Authorizable' do
      let(:headers) { nil }
      let(:method) { :delete }
    end

    it_behaves_like 'API Deletable' do
      let(:method) { :delete }
      let(:resource) { answer }
    end
  end
end
# rubocop:enable Metrics/BlockLength
