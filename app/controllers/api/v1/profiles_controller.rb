# frozen_string_literal: true

class Api::V1::ProfilesController < ApplicationController
  before_action :doorkeeper_authorize!
  skip_authorization_check

  def index
    unauthorized! if cannot? :access, :profile_public_api_call

    @users = User.where.not(id: current_resource_owner.id)
    render json: @users
  end

  def me
    unauthorized! if cannot? :access, :profile_public_api_call

    render json: current_resource_owner
  end

  private

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
