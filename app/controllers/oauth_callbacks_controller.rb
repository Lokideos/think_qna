# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
class OauthCallbacksController < Devise::OmniauthCallbacksController
  authorize_resource

  def github
    @user = User.find_for_oauth(request.env['omniauth.auth'])

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authorization
      set_flash_message(:notice, :success, kind: 'Github') if is_navigational_format?
    else
      session['devise.provider'] = request.env['omniauth.auth'][:provider]
      session['devise.uid'] = request.env['omniauth.auth'][:uid]
      redirect_to create_email_show_path, notice: I18n.t('notifications.oauth_no_email_provided')
    end
  end
end
# rubocop:enable Metrics/AbcSize
