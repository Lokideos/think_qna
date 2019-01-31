# frozen_string_literal: true

class Api::V1::ProfilesController < Api::V1::BaseController
  def index
    @users = User.where.not(id: current_resource_owner.id)
    render json: @users
  end

  def me
    unauthorized! if cannot? :access, :public_api_call

    render json: current_resource_owner
  end
end
