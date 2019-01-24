# frozen_string_literal: true

class Services::GistReadService
  GIST_ID_REGEXP = /\w*$/.freeze

  def initialize(gist_address, client: nil)
    @gist_address = gist_address
    @client = client || Octokit::Client.new(access_token: ENV['GIST_ACCESS'])
  end

  def call
    @client.gist(gist_id)
  end

  private

  def gist_id
    GIST_ID_REGEXP.match(@gist_address).to_s
  end
end
