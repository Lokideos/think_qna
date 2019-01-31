# frozen_string_literal: true

shared_examples_for 'API Linkable' do
  context 'links' do
    let(:links_response) { resource_response_with_links }

    it 'contains links' do
      expect(resource_response_with_links.first['id']).to eq link.id
    end

    it 'contain all related to question links' do
      expect(resource_response_with_links.size).to eq 2
    end

    it 'contains url for links' do
      %w[id url].each do |attr|
        expect(resource_response_with_links.first[attr]).to eq link.send(attr).as_json
      end
    end

    it 'contains only allowed data' do
      expect(resource_response_with_links.first.size).to eq 2
    end
  end
end
