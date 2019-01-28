# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def rewards
    user = User.find(params[:id])
    authorize! :check_rewards, user

    @rewards = user.rewards
  end
end
