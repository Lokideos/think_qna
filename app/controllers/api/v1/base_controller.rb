# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  before_action :doorkeeper_authorize!
  skip_authorization_check
  before_action :auhtorize_shared_public_calls, only: %i[index show]

  private

  def auhtorize_shared_public_calls
    unauthorized! if cannot? :access, :public_api_call
  end

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
