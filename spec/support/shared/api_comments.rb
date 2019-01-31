# frozen_string_literal: true

shared_examples_for 'API Commentable' do
  context 'comments' do
    let(:comments_response) { resource_response_with_comments }

    it 'contains comments' do
      expect(resource_response_with_comments.first['id']).to eq comment.id
    end

    it 'contains all comments' do
      expect(resource_response_with_comments.size).to eq 3
    end

    it 'returns all public fields of comments' do
      %w[id body created_at updated_at].each do |attr|
        expect(resource_response_with_comments.first[attr]).to eq comment.send(attr).as_json
      end
    end
  end
end
