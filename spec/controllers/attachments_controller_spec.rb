# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AttachmentsController, type: :controller do
  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    let(:non_author) { create(:user) }
    let(:resource) { create(:question, user: user) }

    before { resource.files.attach(create_file_blob) }

    context 'used by Author of the resource' do
      before { login(user) }

      it 'deletes file from the database' do
        expect do
          delete :destroy, params: { id: resource.files.last, format: :js }
        end.to change(resource.files, :count).by(-1)
      end

      it 'renders destroy template' do
        delete :destroy, params: { id: resource.files.last, format: :js }
        expect(response).to render_template :destroy
      end
    end

    context 'used by user, who is not Author of the resource' do
      before { login(non_author) }

      it 'does not delete file from the database' do
        expect do
          delete :destroy, params: { id: resource.files.last, format: :js }
        end.to_not change(resource.files, :count)
      end

      it 'redirects to root path' do
        delete :destroy, params: { id: resource.files.last, format: :js }
        expect(response).to redirect_to root_path
      end
    end

    context 'used by unauthenticated user' do
      it 'does not delete file from the database' do
        expect do
          delete :destroy, params: { id: resource.files.last, format: :js }
        end.to_not change(resource.files, :count)
      end

      it 'returns Unauthorized 401 status code' do
        delete :destroy, params: { id: resource.files.last, format: :js }
        expect(response.status).to eq 401
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
