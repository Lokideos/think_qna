# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe LinksController, type: :controller do
  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    let(:non_author) { create(:user) }
    let(:question) { create(:question, user: user) }
    let!(:link) { create(:link, linkable: question) }

    context 'used by Author of related question' do
      before { login(user) }

      it 'deletes link from the database' do
        expect { delete :destroy, params: { id: link, format: :js } }.to change(Link, :count).by(-1)
      end

      it 'renders destroy template' do
        delete :destroy, params: { id: link, format: :js }
        expect(response).to render_template :destroy
      end
    end

    context 'used by user, who is not author of related question' do
      before { login(non_author) }

      it 'does not delete link from the database' do
        expect { delete :destroy, params: { id: link, format: :js } }.to_not change(Link, :count)
      end

      it 'redirects to root path' do
        delete :destroy, params: { id: link, format: :js }
        expect(response).to redirect_to root_path
      end
    end

    context 'user by Unauthenticated user' do
      it 'does not delete link from he database' do
        expect { delete :destroy, params: { id: link, format: :js } }.to_not change(Link, :count)
      end

      it 'return Unauthorized 401 status code' do
        delete :destroy, params: { id: link, format: :js }
        expect(response).to have_http_status(401)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
