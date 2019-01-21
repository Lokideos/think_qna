# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:non_author) { create(:user) }

  describe 'POST #create' do
    let(:question) { create(:question) }

    context 'used by Authenticated user' do
      before { login(user) }

      context 'with valid attributes' do
        it 'creates comment in the database' do
          expect do
            post :create, params: { comment: attributes_for(:comment), question_id: question, format: :json }
          end.to change(Comment, :count).by(1)
        end

        it 'saves correct association to the commentable' do
          post :create, params: { comment: attributes_for(:comment), question_id: question, format: :json }
          expect(assigns(:comment).commentable_id).to eq question.id
        end

        it 'saves correct association to the user' do
          post :create, params: { comment: attributes_for(:comment), question_id: question, format: :json }
          expect(assigns(:comment).user_id).to eq user.id
        end

        it 'returns http 200 Success status code' do
          post :create, params: { comment: attributes_for(:comment), question_id: question.id, format: :json }
          expect(response).to have_http_status 200
        end
      end

      context 'with invalid attributes' do
        it 'does not create comment in the database' do
          expect do
            post :create, params: { comment: attributes_for(:comment, :invalid), question_id: question, format: :json }
          end.to_not change(Comment, :count)
        end

        it 'returns http 422 Unprocessable Entity status' do
          post :create, params: { comment: attributes_for(:comment, :invalid), question_id: question, format: :json }
          expect(response).to have_http_status 422
        end
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not create comment in the database' do
        expect do
          post :create, params: { comment: attributes_for(:comment), question_id: question, format: :json }
        end.to_not change(Comment, :count)
      end

      it 'returns http 401 Unauthorized status code' do
        post :create, params: { comment: attributes_for(:comment), question_id: question, format: :json }
        expect(response).to have_http_status 401
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:comment) { create(:comment, user: user) }

    context 'used by Author of the comment' do
      before { login(user) }

      it 'deletes comment from the database' do
        expect { delete :destroy, params: { id: comment, format: :json } }.to change(Comment, :count).by(-1)
      end

      it 'returns 204 No Content status code' do
        delete :destroy, params: { id: comment, format: :json }
        expect(response).to have_http_status 204
      end
    end

    context 'used by user, who is not author of the comment' do
      before { login(non_author) }

      it 'does not delete comment from the database' do
        expect { delete :destroy, params: { id: comment, format: :json } }.to_not change(Comment, :count)
      end

      it 'redirects to root path' do
        delete :destroy, params: { id: comment, format: :json }
        expect(response).to redirect_to root_path
      end
    end

    context 'used by Unauthenticated user' do
      it 'does not delete comment from the database' do
        expect { delete :destroy, params: { id: comment, format: :json } }.to_not change(Comment, :count)
      end

      it 'returns 401 Unauthorized status code' do
        delete :destroy, params: { id: comment, format: :json }
        expect(response).to have_http_status 401
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
