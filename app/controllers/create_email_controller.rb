# frozen_string_literal: true

class CreateEmailController < ApplicationController
  def show
    @user = User.new
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create
    @user = User.new(user_params)

    if User.exists_with_email?(@user.email)
      User.create_authorization_with_email(@user.email, session['devise.provider'], session['devise.uid'])
      return redirect_to new_user_session_path, notice: 'You account has been link to your Github account.'
    end

    if @user.save_user_for_oauth
      @user.create_authorization(
        OmniAuth::AuthHash.new(provider: session['devise.provider'].to_sym, uid: session['devise.uid'])
      )
      redirect_to root_path, notice: 'Please confirm your account'
    else
      render :show
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
