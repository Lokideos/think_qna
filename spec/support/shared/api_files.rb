# frozen_string_literal: true

shared_examples_for 'API Filable' do
  context 'file links' do
    let(:files_response) { resource_response_with_files }

    before { resource.files.attach(create_file_blob) }
    before { do_request(method, api_path, params: { access_token: access_token.token }, headers: headers) }

    it 'contains files' do
      expect(resource_response_with_files.first['id']).to eq resource.files.first.id
    end

    it 'contains link for files' do
      %w[id service_url].each do |attr|
        expect(resource_response_with_files.first[attr]).to eq resource.files.first.send(attr).as_json
      end
    end

    it 'contains only allowed data' do
      expect(resource_response_with_files.first.size).to eq 2
    end
  end
end
