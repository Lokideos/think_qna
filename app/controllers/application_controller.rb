# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_locale

  def default_url_options
    { lang: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.js do
        @message = exception.message
        render 'shared/exception_alert'
      end

      format.json { render json: exception.message, status: :forbidden }
      format.html { redirect_to root_url, alert: exception.message }
    end
  end

  check_authorization unless: :devise_controller?

  private

  def set_locale
    I18n.locale = I18n.locale_available?(params[:lang]) ? params[:lang] : I18n.default_locale
    cookies[:locale] = I18n.locale
  end
end
