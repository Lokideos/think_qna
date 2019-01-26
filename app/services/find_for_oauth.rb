# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
class Services::FindForOauth
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  def call
    authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s).first
    return authorization.user if authorization

    email = auth.info[:email] if auth.info && auth.info[:email]
    return User.new unless email

    user = User.find_by(email: email)

    unless user
      password = Devise.friendly_token[0, 20]
      user = User.create!(email: email, password: password, password_confirmation: password, confirmed_at: DateTime.now)
    end
    user.create_authorization(auth)

    user
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
