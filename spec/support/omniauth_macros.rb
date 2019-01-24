# frozen_string_literal: true

module OmniauthMacros
  def mock_auth_hash
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid: '123456',
      info: {
        email: 'example@info.com'
      },
      credentials: {
        token: 'mock_token'
      }
    )
  end

  def invalid_mock_auth_hash
    OmniAuth.config.mock_auth[:github] = :invalid_credentials
  end
end
