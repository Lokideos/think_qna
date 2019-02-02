# frozen_string_literal: true

shared_examples_for 'API Deletable' do
  context 'authorized' do
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }

    it 'returns 200 status' do
      do_request(method, api_path, params: { access_token: access_token.token, format: :json })
      expect(response).to be_successful
    end

    it 'deletes answer from the database' do
      expect do
        do_request(method, api_path, params: { access_token: access_token.token, format: :json })
      end.to change(resource.class, :count).by(-1)
    end
  end
end
