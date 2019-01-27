# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_locale

  def default_url_options
    { lang: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  check_authorization unless: :devise_controller?

  private

  def set_locale
    I18n.locale = I18n.locale_available?(params[:lang]) ? params[:lang] : I18n.default_locale
    cookies[:locale] = I18n.locale
  end
end
