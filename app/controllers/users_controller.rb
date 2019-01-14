# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def rewards
    user = User.find(params[:id])
    return redirect_to root_path, notice: "You can't check other user's rewards." unless current_user == user

    @rewards = user.rewards
  end
end
