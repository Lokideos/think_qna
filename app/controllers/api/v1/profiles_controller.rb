# frozen_string_literal: true

class Api::V1::ProfilesController < ApplicationController
  before_action :doorkeeper_authorize!
  authorize_resource

  def me
    head :ok
  end
end
