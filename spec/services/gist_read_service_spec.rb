# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GistReadService do
  describe '#call' do
    let(:gist_id) { 'c6af77d52547287a49d9c140e9816391' }
    let(:bad_gist_id) { 'bad_gist_id' }
    let(:client) { Octokit::Client.new(access_token: ENV['GIST_ACCESS']) }

    it 'should return Octokit Sawyer::Resource object' do
      expect(client.gist(gist_id)).to be_a(Sawyer::Resource)
    end

    it 'should throw exception if gist id is not correct' do
      client.gist(bad_gist_id)
    rescue StandardError => e
      expect(e.class).to be 'Octokit::NotFound'.constantize
    end
  end
end
