# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def rewards
    user = User.find(params[:id])
    return redirect_to root_path, notice: t('notifications.forbidden_for_non_author') unless current_user == user

    @rewards = user.rewards
  end
end
