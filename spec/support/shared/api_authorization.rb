# frozen_string_literal: true

shared_examples_for 'API Authorizable' do
  context 'unauthorized' do
    it 'returns 401 Unauthorized status if there is no access token' do
      do_request(method, api_path, headers: headers)
      expect(response).to have_http_status 401
    end

    it 'returns 401 Unauthorized status if access token is invalid' do
      do_request(method, api_path, params: { access_token: '1234' }, headers: headers)
      expect(response).to have_http_status 401
    end
  end
end
